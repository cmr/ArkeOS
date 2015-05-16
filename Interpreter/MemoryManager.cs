﻿using System;
using System.IO;

namespace ArkeOS.Interpreter {
	public class MemoryManager {
		private byte[] memory;

		public MemoryManager() {
			this.memory = new byte[1 * 1024 * 1024];

			this.Reader = new BinaryReader(new MemoryStream(this.memory));
		}

		public ulong this[ulong address] {
			get {
				return this.ReadU64(address);
			}
			set {
				this.WriteU64(address, value);
			}
		}

		public BinaryReader Reader { get; }

		public byte ReadU8(ulong address) => this.memory[address];
		public ushort ReadU16(ulong address) => BitConverter.ToUInt16(this.memory, (int)address);
		public uint ReadU32(ulong address) => BitConverter.ToUInt32(this.memory, (int)address);
		public ulong ReadU64(ulong address) => BitConverter.ToUInt64(this.memory, (int)address);
		public void WriteU8(ulong address, byte data) => this.memory[address] = data;
		public void WriteU16(ulong address, ushort data) => this.CopyFrom(BitConverter.GetBytes(data), address, 2);
		public void WriteU32(ulong address, uint data) => this.CopyFrom(BitConverter.GetBytes(data), address, 4);
		public void WriteU64(ulong address, ulong data) => this.CopyFrom(BitConverter.GetBytes(data), address, 8);

		public void Copy(ulong source, ulong destination, ulong length) {
			Array.Copy(this.memory, (long)source, this.memory, (long)destination, (long)length);
		}

		public void CopyFrom(byte[] source, ulong destination, ulong length) {
			Array.Copy(source, 0, this.memory, (long)destination, (long)length);
		}

		public void CopyTo(byte[] destination, ulong source, ulong length) {
			Array.Copy(this.memory, 0, destination, (long)source, (long)length);
		}
	}
}