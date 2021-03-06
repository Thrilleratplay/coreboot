/* SPDX-License-Identifier: GPL-2.0-only */

#include <acpi/acpi_gnvs.h>
#include <acpi/acpigen.h>
#include <cbmem.h>
#include <console/console.h>
#include <soc/nvs.h>
#include <stdint.h>
#include <string.h>
#include <types.h>
#include <vendorcode/google/chromeos/gnvs.h>

static struct global_nvs *gnvs;

void acpi_create_gnvs(void)
{
	size_t gnvs_size;

	gnvs = cbmem_find(CBMEM_ID_ACPI_GNVS);
	if (gnvs)
		return;

	/* Match with OpRegion declared in global_nvs.asl. */
	gnvs_size = sizeof(struct global_nvs);
	if (gnvs_size < 0x100)
		gnvs_size = 0x100;
	if (CONFIG(ACPI_HAS_DEVICE_NVS))
		gnvs_size = 0x2000;
	else if (CONFIG(CHROMEOS_NVS))
		gnvs_size = 0x1000;

	gnvs = cbmem_add(CBMEM_ID_ACPI_GNVS, gnvs_size);
	if (!gnvs)
		return;

	memset(gnvs, 0, gnvs_size);

	if (CONFIG(CONSOLE_CBMEM))
		gnvs->cbmc = (uintptr_t)cbmem_find(CBMEM_ID_CONSOLE);

	if (CONFIG(CHROMEOS_NVS)) {
		chromeos_acpi_t *init = (void *)((u8 *)gnvs + GNVS_CHROMEOS_ACPI_OFFSET);
		chromeos_init_chromeos_acpi(init);
	}
}

void *acpi_get_gnvs(void)
{
	if (gnvs)
		return gnvs;

	gnvs = cbmem_find(CBMEM_ID_ACPI_GNVS);
	if (gnvs)
		return gnvs;

	printk(BIOS_ERR, "Unable to locate Global NVS\n");
	return NULL;
}

void *acpi_get_device_nvs(void)
{
	return (u8 *)gnvs + GNVS_DEVICE_NVS_OFFSET;
}

/* Implemented under platform. */
__weak void soc_fill_gnvs(struct global_nvs *gnvs_) { }
__weak void mainboard_fill_gnvs(struct global_nvs *gnvs_) { }

/* Called from write_acpi_tables() only on normal boot path. */
void acpi_fill_gnvs(void)
{
	const struct opregion gnvs_op = OPREGION("GNVS", SYSTEMMEMORY, (uintptr_t)gnvs, 0x100);
	const struct opregion cnvs_op =	OPREGION("CNVS", SYSTEMMEMORY,
					(uintptr_t)gnvs + GNVS_CHROMEOS_ACPI_OFFSET, 0xf00);
	const struct opregion dnvs_op = OPREGION("DNVS", SYSTEMMEMORY,
					(uintptr_t)gnvs + GNVS_DEVICE_NVS_OFFSET, 0x1000);

	if (!gnvs)
		return;

	soc_fill_gnvs(gnvs);
	mainboard_fill_gnvs(gnvs);

	acpigen_write_scope("\\");
	acpigen_write_opregion(&gnvs_op);

	if (CONFIG(CHROMEOS_NVS))
		acpigen_write_opregion(&cnvs_op);

	if (CONFIG(ACPI_HAS_DEVICE_NVS))
		acpigen_write_opregion(&dnvs_op);

	acpigen_pop_len();
}

int acpi_reset_gnvs_for_wake(struct global_nvs **gnvs_)
{
	if (!gnvs)
		return -1;

	/* Set unknown wake source */
	gnvs->pm1i = -1;
	gnvs->gpei = -1;

	*gnvs_ = gnvs;
	return 0;
}
