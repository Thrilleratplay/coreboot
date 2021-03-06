/* Bochs/QEMU ACPI DSDT ASL definition */
/* SPDX-License-Identifier: GPL-2.0-only */

/*
 * Based on acpi-dsdt.dsl, but heavily modified for q35 chipset.
 */

#include <acpi/acpi.h>
DefinitionBlock (
	"dsdt.aml",
	"DSDT",
	ACPI_DSDT_REV_1,
	OEM_ID,
	ACPI_TABLE_CREATOR,
	0x2                 // OEM Revision
	)
{
	#include <acpi/dsdt_top.asl>

#include "../qemu-i440fx/acpi/dbug.asl"

	Scope(\_SB) {
		OperationRegion(PCST, SystemIO, 0xae00, 0x0c)
		OperationRegion(PCSB, SystemIO, 0xae0c, 0x01)
		Field(PCSB, AnyAcc, NoLock, WriteAsZeros) {
			PCIB, 8,
		}
	}


/****************************************************************
 * PCI Bus definition
 ****************************************************************/

	Scope(\_SB) {
		Device(PCI0) {
			Name(_HID, EisaId("PNP0A08"))
			Name(_CID, EisaId("PNP0A03"))
			Name(_UID, 1)

			// _OSC: based on sample of ACPI3.0b spec
			Name(SUPP, 0) // PCI _OSC Support Field value
			Name(CTRL, 0) // PCI _OSC Control Field value
			Method(_OSC, 4) {
				// Create DWORD-addressable fields from the Capabilities Buffer
				CreateDWordField(Arg3, 0, CDW1)

				// Check for proper UUID
				If (Arg0 == ToUUID("33DB4D5B-1FF7-401C-9657-7441C03DD766")) {
					// Create DWORD-addressable fields from the Capabilities Buffer
					CreateDWordField(Arg3, 4, CDW2)
					CreateDWordField(Arg3, 8, CDW3)

					// Save Capabilities DWORD2 & 3
					SUPP = CDW2
					CTRL = CDW3

					// Always allow native PME, AER (no dependencies)
					// Never allow SHPC (no SHPC controller in this system)
					CTRL &= 0x1D

					If (Arg1 != 1) {
						// Unknown revision
						CDW1 |= 0x08
					}
					If (CDW3 != CTRL) {
						// Capabilities bits were masked
						CDW1 |= 0x10
					}
					// Update DWORD3 in the buffer
					CDW3 = CTRL
				} Else {
					CDW1 |= 4 // Unrecognized UUID
				}
				Return (Arg3)
			}
		}
	}

#include "../qemu-i440fx/acpi/pci-crs.asl"
#include "../qemu-i440fx/acpi/hpet.asl"


/****************************************************************
 * VGA
 ****************************************************************/

	Scope(\_SB.PCI0) {
		Device(VGA) {
			Name(_ADR, 0x00010000)
			Method(_S1D, 0, NotSerialized) {
				Return (0x00)
			}
			Method(_S2D, 0, NotSerialized) {
				Return (0x00)
			}
			Method(_S3D, 0, NotSerialized) {
				Return (0x00)
			}
		}
	}


/****************************************************************
 * LPC ISA bridge
 ****************************************************************/

	Scope(\_SB.PCI0) {
		/* PCI D31:f0 LPC ISA bridge */
		Device(ISA) {
			/* PCI D31:f0 */
			Name(_ADR, 0x001f0000)

			/* ICH9 PCI to ISA irq remapping */
			OperationRegion(PIRQ, PCI_Config, 0x60, 0x0C)

			OperationRegion(LPCD, PCI_Config, 0x80, 0x2)
			Field(LPCD, AnyAcc, NoLock, Preserve) {
				COMA,   3,
				,   1,
				COMB,   3,

				Offset(0x01),
				LPTD,   2,
				,   2,
				FDCD,   2
			}
			OperationRegion(LPCE, PCI_Config, 0x82, 0x2)
			Field(LPCE, AnyAcc, NoLock, Preserve) {
				CAEN,   1,
				CBEN,   1,
				LPEN,   1,
				FDEN,   1
			}
		}
	}

#include "../qemu-i440fx/acpi/isa.asl"


/****************************************************************
 * PCI IRQs
 ****************************************************************/

	Scope(\_SB) {
		Scope(PCI0) {
#define prt_slot_lnk(nr, lnk0, lnk1, lnk2, lnk3)  \
	Package() { nr##ffff, 0, lnk0, 0 },           \
	Package() { nr##ffff, 1, lnk1, 0 },           \
	Package() { nr##ffff, 2, lnk2, 0 },           \
	Package() { nr##ffff, 3, lnk3, 0 }

#define prt_slot_lnkA(nr) prt_slot_lnk(nr, LNKA, LNKB, LNKC, LNKD)
#define prt_slot_lnkB(nr) prt_slot_lnk(nr, LNKB, LNKC, LNKD, LNKA)
#define prt_slot_lnkC(nr) prt_slot_lnk(nr, LNKC, LNKD, LNKA, LNKB)
#define prt_slot_lnkD(nr) prt_slot_lnk(nr, LNKD, LNKA, LNKB, LNKC)

#define prt_slot_lnkE(nr) prt_slot_lnk(nr, LNKE, LNKF, LNKG, LNKH)
#define prt_slot_lnkF(nr) prt_slot_lnk(nr, LNKF, LNKG, LNKH, LNKE)
#define prt_slot_lnkG(nr) prt_slot_lnk(nr, LNKG, LNKH, LNKE, LNKF)
#define prt_slot_lnkH(nr) prt_slot_lnk(nr, LNKH, LNKE, LNKF, LNKG)

			Name(PRTP, Package() {
				prt_slot_lnkE(0x0000),
				prt_slot_lnkF(0x0001),
				prt_slot_lnkG(0x0002),
				prt_slot_lnkH(0x0003),
				prt_slot_lnkE(0x0004),
				prt_slot_lnkF(0x0005),
				prt_slot_lnkG(0x0006),
				prt_slot_lnkH(0x0007),
				prt_slot_lnkE(0x0008),
				prt_slot_lnkF(0x0009),
				prt_slot_lnkG(0x000a),
				prt_slot_lnkH(0x000b),
				prt_slot_lnkE(0x000c),
				prt_slot_lnkF(0x000d),
				prt_slot_lnkG(0x000e),
				prt_slot_lnkH(0x000f),
				prt_slot_lnkE(0x0010),
				prt_slot_lnkF(0x0011),
				prt_slot_lnkG(0x0012),
				prt_slot_lnkH(0x0013),
				prt_slot_lnkE(0x0014),
				prt_slot_lnkF(0x0015),
				prt_slot_lnkG(0x0016),
				prt_slot_lnkH(0x0017),
				prt_slot_lnkE(0x0018),

				/* INTA -> PIRQA for slot 25 - 31
				  see the default value of D<N>IR */
				prt_slot_lnkA(0x0019),
				prt_slot_lnkA(0x001a),
				prt_slot_lnkA(0x001b),
				prt_slot_lnkA(0x001c),
				prt_slot_lnkA(0x001d),

				/* PCIe->PCI bridge. use PIRQ[E-H] */
				prt_slot_lnkE(0x001e),

				prt_slot_lnkA(0x001f)
			})

#define prt_slot_gsi(nr, gsi0, gsi1, gsi2, gsi3)  \
	Package() { nr##ffff, 0, gsi0, 0 },           \
	Package() { nr##ffff, 1, gsi1, 0 },           \
	Package() { nr##ffff, 2, gsi2, 0 },           \
	Package() { nr##ffff, 3, gsi3, 0 }

#define prt_slot_gsiA(nr) prt_slot_gsi(nr, GSIA, GSIB, GSIC, GSID)
#define prt_slot_gsiB(nr) prt_slot_gsi(nr, GSIB, GSIC, GSID, GSIA)
#define prt_slot_gsiC(nr) prt_slot_gsi(nr, GSIC, GSID, GSIA, GSIB)
#define prt_slot_gsiD(nr) prt_slot_gsi(nr, GSID, GSIA, GSIB, GSIC)

#define prt_slot_gsiE(nr) prt_slot_gsi(nr, GSIE, GSIF, GSIG, GSIH)
#define prt_slot_gsiF(nr) prt_slot_gsi(nr, GSIF, GSIG, GSIH, GSIE)
#define prt_slot_gsiG(nr) prt_slot_gsi(nr, GSIG, GSIH, GSIE, GSIF)
#define prt_slot_gsiH(nr) prt_slot_gsi(nr, GSIH, GSIE, GSIF, GSIG)

			Name(PRTA, Package() {
				prt_slot_gsiE(0x0000),
				prt_slot_gsiF(0x0001),
				prt_slot_gsiG(0x0002),
				prt_slot_gsiH(0x0003),
				prt_slot_gsiE(0x0004),
				prt_slot_gsiF(0x0005),
				prt_slot_gsiG(0x0006),
				prt_slot_gsiH(0x0007),
				prt_slot_gsiE(0x0008),
				prt_slot_gsiF(0x0009),
				prt_slot_gsiG(0x000a),
				prt_slot_gsiH(0x000b),
				prt_slot_gsiE(0x000c),
				prt_slot_gsiF(0x000d),
				prt_slot_gsiG(0x000e),
				prt_slot_gsiH(0x000f),
				prt_slot_gsiE(0x0010),
				prt_slot_gsiF(0x0011),
				prt_slot_gsiG(0x0012),
				prt_slot_gsiH(0x0013),
				prt_slot_gsiE(0x0014),
				prt_slot_gsiF(0x0015),
				prt_slot_gsiG(0x0016),
				prt_slot_gsiH(0x0017),
				prt_slot_gsiE(0x0018),

				/* INTA -> PIRQA for slot 25 - 31, but 30
				  see the default value of D<N>IR */
				prt_slot_gsiA(0x0019),
				prt_slot_gsiA(0x001a),
				prt_slot_gsiA(0x001b),
				prt_slot_gsiA(0x001c),
				prt_slot_gsiA(0x001d),

				/* PCIe->PCI bridge. use PIRQ[E-H] */
				prt_slot_gsiE(0x001e),

				prt_slot_gsiA(0x001f)
			})

			Method(_PRT, 0, NotSerialized) {
				/* PCI IRQ routing table, example from ACPI 2.0a specification,
				  section 6.2.8.1 */
				/* Note: we provide the same info as the PCI routing
				  table of the Bochs BIOS */
				If (\PICM ==  0) {
					Return (PRTP)
				} Else {
					Return (PRTA)
				}
			}
		}

		Field(PCI0.ISA.PIRQ, ByteAcc, NoLock, Preserve) {
			PRQA,   8,
			PRQB,   8,
			PRQC,   8,
			PRQD,   8,

			Offset(0x08),
			PRQE,   8,
			PRQF,   8,
			PRQG,   8,
			PRQH,   8
		}

		Method(IQST, 1, NotSerialized) {
			// _STA method - get status
			If (0x80 & Arg0) {
				Return (0x09)
			}
			Return (0x0B)
		}
		Method(IQCR, 1, Serialized) {
			// _CRS method - get current settings
			Name(PRR0, ResourceTemplate() {
				Interrupt(, Level, ActiveHigh, Shared) { 0 }
			})
			CreateDWordField(PRR0, 0x05, PRRI)
			PRRI = Arg0 & 0x0F
			Return (PRR0)
		}

#define define_link(link, uid, reg)                             \
		Device(link) {                                          \
			Name(_HID, EISAID("PNP0C0F"))                       \
			Name(_UID, uid)                                     \
			Name(_PRS, ResourceTemplate() {                     \
				Interrupt(, Level, ActiveHigh, Shared) {        \
				5, 10, 11                                   \
				}                                               \
			})                                                  \
			Method(_STA, 0, NotSerialized) {                    \
				Return (IQST(reg))                              \
			}                                                   \
			Method(_DIS, 0, NotSerialized) {                    \
				reg |= 0x80                              \
			}                                                   \
			Method(_CRS, 0, NotSerialized) {                    \
				Return (IQCR(reg))                              \
			}                                                   \
			Method(_SRS, 1, NotSerialized) {                    \
				CreateDWordField(Arg0, 0x05, PRRI)              \
				reg = PRRI                                \
			}                                                   \
		}

		define_link(LNKA, 0, PRQA)
		define_link(LNKB, 1, PRQB)
		define_link(LNKC, 2, PRQC)
		define_link(LNKD, 3, PRQD)
		define_link(LNKE, 4, PRQE)
		define_link(LNKF, 5, PRQF)
		define_link(LNKG, 6, PRQG)
		define_link(LNKH, 7, PRQH)

#define define_gsi_link(link, uid, gsi)                         \
		Device(link) {                                          \
			Name(_HID, EISAID("PNP0C0F"))                       \
			Name(_UID, uid)                                     \
			Name(_PRS, ResourceTemplate() {                     \
				Interrupt(, Level, ActiveHigh, Shared) {        \
				gsi                                         \
				}                                               \
			})                                                  \
			Name(_CRS, ResourceTemplate() {                     \
				Interrupt(, Level, ActiveHigh, Shared) {        \
				gsi                                         \
				}                                               \
			})                                                  \
			Method(_SRS, 1, NotSerialized) {                    \
			}                                                   \
		}

		define_gsi_link(GSIA, 0, 0x10)
		define_gsi_link(GSIB, 0, 0x11)
		define_gsi_link(GSIC, 0, 0x12)
		define_gsi_link(GSID, 0, 0x13)
		define_gsi_link(GSIE, 0, 0x14)
		define_gsi_link(GSIF, 0, 0x15)
		define_gsi_link(GSIG, 0, 0x16)
		define_gsi_link(GSIH, 0, 0x17)
	}

/****************************************************************
 * General purpose events
 ****************************************************************/

	Scope(\_GPE) {
		Name(_HID, "ACPI0006")

		Method(_L00) {
		}
		Method(_L01) {
		}
		Method(_L02) {
		}
		Method(_L03) {
		}
		Method(_L04) {
		}
		Method(_L05) {
		}
		Method(_L06) {
		}
		Method(_L07) {
		}
		Method(_L08) {
		}
		Method(_L09) {
		}
		Method(_L0A) {
		}
		Method(_L0B) {
		}
		Method(_L0C) {
		}
		Method(_L0D) {
		}
		Method(_L0E) {
		}
		Method(_L0F) {
		}
	}
}
