﻿using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using ArkeOS.Architecture;

namespace ArkeOS.Assembler {
	public class Assembler {
		private Dictionary<string, ulong> labels;
		private string inputFile;

		public Assembler(string inputFile) {
			this.labels = new Dictionary<string, ulong>();
			this.inputFile = inputFile;
		}

		public byte[] Assemble() {
			var lines = File.ReadAllLines(this.inputFile).Where(l => !string.IsNullOrWhiteSpace(l)).Select(l => l.Replace(" + ", "+").Replace(" * ", "*").Replace(" - ", "-"));

			using (var stream = new MemoryStream()) {
				using (var writer = new BinaryWriter(stream)) {

					this.DiscoverLabelAddresses(lines);

					foreach (var line in lines) {
						var parts = line.Split(' ');

						if (parts[0] == "ORIGIN") {
							stream.Seek((long)Helpers.ParseLiteral(parts[1]), SeekOrigin.Begin);
						}
						else if (parts[0] == "LABEL") {

						}
						else if (parts[0].StartsWith("CONST")) {
							if (parts[1].StartsWith("0")) {
								writer.Write(Helpers.ParseLiteral(parts[1]));
							}
							else {
								writer.Write(this.labels[parts[1].Substring(1, parts[1].Length - 2).Trim()]);
							}
						}
						else if (parts[0] == "STRING") {
							var start = line.IndexOf("\"") + 1;
							var end = line.LastIndexOf("\"");

							writer.Write(Encoding.UTF8.GetBytes(line.Substring(start, end - start)));
						}
						else if (!parts[0].StartsWith(@"//")) {
							this.ParseInstruction(parts, true).Encode(writer);
						}
					}

					return stream.ToArray();
				}
			}
		}

		private void DiscoverLabelAddresses(IEnumerable<string> lines) {
			var address = 0UL;

			foreach (var line in lines) {
				var parts = line.Split(' ');

				if (parts[0] == "ORIGIN") {
					address = Helpers.ParseLiteral(parts[1]);
				}
				else if (parts[0] == "LABEL") {
					this.labels.Add(parts[1], address);
				}
				else if (parts[0].StartsWith("CONST")) {
					address += 8;
				}
				else if (parts[0] == "STRING") {
					var start = line.IndexOf("\"") + 1;
					var end = line.LastIndexOf("\"");

					address += (ulong)(end - start);
				}
				else if (!parts[0].StartsWith(@"//")) {
					address += this.ParseInstruction(parts, false).Length;
				}
			}
		}

		private Instruction ParseInstruction(string[] parts, bool resolveLabels) {
			var def = InstructionDefinition.Find(parts[0]);

			if (def == null)
				throw new InvalidInstructionException();

			return new Instruction(def.Code, parts.Skip(1).Select(p => this.ParseParameter(p, resolveLabels)).ToList());
		}

		private Parameter ParseParameter(string value, bool resolveLabels) {
			var isAddress = value[0] == '[';

			if (isAddress)
				value = value.Substring(1, value.Length - 2);

			if (value[0] == '(') {
				value = value.Substring(1, value.Length - 2);

				var parts = value.Split('+', '-', '*');
				var calculatedBase = this.ParseParameter(parts[0], resolveLabels);
				var calculatedIndex = this.ParseParameter(parts[1], resolveLabels);
				var calculatedScale = (parts.Length > 2 && !string.IsNullOrWhiteSpace(parts[2])) ? this.ParseParameter(parts[2], resolveLabels) : null;
				var calculatedOffset = (parts.Length > 3 && !string.IsNullOrWhiteSpace(parts[3])) ? this.ParseParameter(parts[3], resolveLabels) : null;

				return Parameter.CreateCalculated(isAddress, calculatedBase, calculatedIndex, calculatedScale, calculatedOffset, value[parts[0].Length] == '+');
			}
			else if (value[0] == '{') {
				return Parameter.CreateLiteral(isAddress, resolveLabels ? this.labels[value.Substring(1, value.Length - 2)] : 0);
			}
			else if (value[0] == '0') {
				return Parameter.CreateLiteral(isAddress, Helpers.ParseLiteral(value));
			}
			else if (value[0] == 'R') {
				return Parameter.CreateRegister(isAddress, Helpers.ParseEnum<Register>(value));
			}
			else if (value == "S") {
				return Parameter.CreateStack(isAddress);
			}
			else {
				return null;
			}
		}
	}
}