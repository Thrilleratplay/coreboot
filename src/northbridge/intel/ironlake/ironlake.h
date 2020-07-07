/* SPDX-License-Identifier: GPL-2.0-only */

#ifndef __NORTHBRIDGE_INTEL_IRONLAKE_IRONLAKE_H__
#define __NORTHBRIDGE_INTEL_IRONLAKE_IRONLAKE_H__

#define DEFAULT_HECIBAR		((u8 *)0xfed17000)


#define IOMMU_BASE1 0xfed90000
#define IOMMU_BASE2 0xfed91000
#define IOMMU_BASE3 0xfed92000
#define IOMMU_BASE4 0xfed93000

/*
 * D0:F0
 */
#define D0F0_EPBAR_LO		0x40
#define D0F0_EPBAR_HI		0x44
#define D0F0_MCHBAR_LO		0x48
#define D0F0_MCHBAR_HI		0x4c
#define D0F0_GGC		0x52
#define D0F0_DEVEN		0x54
#define  DEVEN_IGD		(1 << 3)
#define  DEVEN_PEG10		(1 << 1)
#define  DEVEN_HOST		(1 << 0)
#define D0F0_PCIEXBAR_LO	0x60
#define D0F0_PCIEXBAR_HI	0x64
#define D0F0_DMIBAR_LO		0x68
#define D0F0_DMIBAR_HI		0x6c
#define D0F0_PMBASE		0x78
#define QPD0F1_PAM(x)		(0x40 + (x)) /* 0-6 */
#define D0F0_REMAPBASE		0x98
#define D0F0_REMAPLIMIT		0x9a
#define D0F0_TOM		0xa0
#define D0F0_TOUUD		0xa2
#define D0F0_IGD_BASE		0xa4
#define D0F0_GTT_BASE		0xa8
#define D0F0_TOLUD		0xb0
#define D0F0_SKPD		0xdc /* Scratchpad Data */

#define D0F0_CAPID0		0xe0

#define TSEG			0xac /* TSEG base */

/*
 * D1:F0 PEG
 */
#define PEG_CAP		0xa2
#define SLOTCAP		0xb4
#define PEGLC		0xec
#define D1F0_VCCAP	0x104
#define D1F0_VC0RCTL	0x114

/* Chipset types */
#define IRONLAKE_MOBILE		0
#define IRONLAKE_DESKTOP	1
#define IRONLAKE_SERVER		2

/* Northbridge BARs */
#ifndef __ACPI__
#define DEFAULT_MCHBAR		((u8 *)0xfed10000)	/* 16 KB */
#define DEFAULT_DMIBAR		((u8 *)0xfed18000)	/* 4 KB */
#else
#define DEFAULT_MCHBAR		0xfed10000	/* 16 KB */
#define DEFAULT_DMIBAR		0xfed18000	/* 4 KB */
#endif
#define DEFAULT_EPBAR		0xfed19000	/* 4 KB */
#define DEFAULT_RCBABASE	((u8 *)0xfed1c000)

#define QUICKPATH_BUS 0xff

#include <southbridge/intel/ibexpeak/pch.h>

/* Everything below this line is ignored in the DSDT */
#ifndef __ACPI__

/* Device 0:0.0 PCI configuration space (Host Bridge) */

#define EPBAR		0x40
#define MCHBAR		0x48
#define PCIEXBAR	0x60
#define DMIBAR		0x68
#define X60BAR		0x60

#define LAC		0x87	/* Legacy Access Control */
#define QPD0F1_SMRAM		0x4d	/* System Management RAM Control */

#define SKPAD		0xdc	/* Scratchpad Data */


/* Device 0:2.0 PCI configuration space (Graphics Device) */

#define MSAC		0x62	/* Multi Size Aperture Control */

/*
 * MCHBAR
 */

#define MCHBAR8(x)			(*((volatile u8  *)(DEFAULT_MCHBAR + (x))))
#define MCHBAR16(x)			(*((volatile u16 *)(DEFAULT_MCHBAR + (x))))
#define MCHBAR32(x)			(*((volatile u32 *)(DEFAULT_MCHBAR + (x))))
#define MCHBAR8_AND(x,  and)		(MCHBAR8(x)  = MCHBAR8(x)  & (and))
#define MCHBAR16_AND(x, and)		(MCHBAR16(x) = MCHBAR16(x) & (and))
#define MCHBAR32_AND(x, and)		(MCHBAR32(x) = MCHBAR32(x) & (and))
#define MCHBAR8_OR(x,  or)		(MCHBAR8(x)  = MCHBAR8(x)  | (or))
#define MCHBAR16_OR(x, or)		(MCHBAR16(x) = MCHBAR16(x) | (or))
#define MCHBAR32_OR(x, or)		(MCHBAR32(x) = MCHBAR32(x) | (or))
#define MCHBAR8_AND_OR(x,  and, or)	(MCHBAR8(x)  = (MCHBAR8(x)  & (and)) | (or))
#define MCHBAR16_AND_OR(x, and, or)	(MCHBAR16(x) = (MCHBAR16(x) & (and)) | (or))
#define MCHBAR32_AND_OR(x, and, or)	(MCHBAR32(x) = (MCHBAR32(x) & (and)) | (or))
/*
 * EPBAR - Egress Port Root Complex Register Block
 */

#define EPBAR8(x)	(*((volatile u8  *)(DEFAULT_EPBAR + (x))))
#define EPBAR16(x)	(*((volatile u16 *)(DEFAULT_EPBAR + (x))))
#define EPBAR32(x)	(*((volatile u32 *)(DEFAULT_EPBAR + (x))))

#define EPPVCCAP1	0x004	/* 32bit */
#define EPPVCCAP2	0x008	/* 32bit */

#define EPVC0RCAP	0x010	/* 32bit */
#define EPVC0RCTL	0x014	/* 32bit */
#define EPVC0RSTS	0x01a	/* 16bit */

#define EPVC1RCAP	0x01c	/* 32bit */
#define EPVC1RCTL	0x020	/* 32bit */
#define EPVC1RSTS	0x026	/* 16bit */

#define EPVC1MTS	0x028	/* 32bit */
#define EPVC1IST	0x038	/* 64bit */

#define EPESD		0x044	/* 32bit */

#define EPLE1D		0x050	/* 32bit */
#define EPLE1A		0x058	/* 64bit */
#define EPLE2D		0x060	/* 32bit */
#define EPLE2A		0x068	/* 64bit */

#define PORTARB		0x100	/* 256bit */

/*
 * DMIBAR
 */

#define DMIBAR8(x)	(*((volatile u8  *)(DEFAULT_DMIBAR + (x))))
#define DMIBAR16(x)	(*((volatile u16 *)(DEFAULT_DMIBAR + (x))))
#define DMIBAR32(x)	(*((volatile u32 *)(DEFAULT_DMIBAR + (x))))

#define DMIVCECH	0x000	/* 32bit */
#define DMIPVCCAP1	0x004	/* 32bit */
#define DMIPVCCAP2	0x008	/* 32bit */

#define DMIPVCCCTL	0x00c	/* 16bit */

#define DMIVC0RCAP	0x010	/* 32bit */
#define DMIVC0RCTL	0x014	/* 32bit */
#define DMIVC0RSTS	0x01a	/* 16bit */

#define DMIVC1RCAP	0x01c	/* 32bit */
#define DMIVC1RCTL	0x020	/* 32bit */
#define DMIVC1RSTS	0x026	/* 16bit */

#define DMILE1D		0x050	/* 32bit */
#define DMILE1A		0x058	/* 64bit */
#define DMILE2D		0x060	/* 32bit */
#define DMILE2A		0x068	/* 64bit */

#define DMILCAP		0x084	/* 32bit */
#define DMILCTL		0x088	/* 16bit */
#define DMILSTS		0x08a	/* 16bit */

#define DMICTL1		0x0f0	/* 32bit */
#define DMICTL2		0x0fc	/* 32bit */

#define DMICC		0x208	/* 32bit */

#define DMIDRCCFG	0xeb4	/* 32bit */

#ifndef __ASSEMBLER__

void intel_ironlake_finalize_smm(void);

int bridge_silicon_revision(void);
void ironlake_early_initialization(int chipset_type);
void ironlake_late_initialization(void);
void mainboard_pre_raminit(void);
void mainboard_get_spd_map(u8 *spd_addrmap);

#endif
#endif
#endif /* __NORTHBRIDGE_INTEL_IRONLAKE_IRONLAKE_H__ */