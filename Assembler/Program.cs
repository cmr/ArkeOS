﻿using System;
using System.IO;
using ArkeOS.Executable;
using ArkeOS.ISA;

namespace ArkeOS.Assembler {
	public static class Program {
		private static bool CheckArgs(string[] args, out string input, out string output) {
			input = string.Empty;
			output = string.Empty;

			if (args.Length != 2) {
				input = "../../Program.asm";
				output = "../../../Virtual Machine/Program.aoe";
			}
			else {
				input = args[0];
				output = args[1];
			}

			if (!File.Exists(input)) {
				Console.WriteLine("The specified file cannot be found.");

				return false;
			}

			return true;
		}

		private static byte[] Assemble(string input) {
			Section currentSection = null;
			var image = new Image();
			var lines = File.ReadAllLines(input);
			var pendingLabel = string.Empty;

			foreach (var line in lines) {
				var parts = line.Split(' ');

				switch (parts[0]) {
					case "ENTRY":
						image.Header.EntryPointAddress = Convert.ToUInt64(parts[1], 16);

						break;

					case "STACK":
						image.Header.StackAddress = Convert.ToUInt64(parts[1], 16);

						break;

					case "ORIGIN":
						currentSection = new Section(Convert.ToUInt64(parts[1], 16));

						image.Sections.Add(currentSection);

						break;

					case "LABEL":
						pendingLabel = parts[1];

						break;

					default:
						if (string.IsNullOrWhiteSpace(parts[0]) || parts[0].TrimStart().IndexOf("//") == 0)
							continue;

						currentSection.AddInstruction(new Instruction(parts, pendingLabel));
						pendingLabel = string.Empty;

						break;

				}
			}

			return image.ToArray();
		}

		public static void Main(string[] args) {
			string input, output;

			if (!Program.CheckArgs(args, out input, out output))
				return;

			File.WriteAllBytes(output, Program.Assemble(input));
		}
	}
}