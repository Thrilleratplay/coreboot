/* SPDX-License-Identifier: GPL-2.0-only */

#include <console/console.h>
#include <string.h>
#include <soc/dramc_param.h>

#define print(_x_...) printk(BIOS_INFO, _x_)

struct dramc_param *get_dramc_param_from_blob(void *blob)
{
	return (struct dramc_param *)blob;
}

void dump_param_header(const void *blob)
{
	const struct dramc_param *dparam = blob;
	const struct dramc_param_header *header = &dparam->header;

	print("header.status = %#x\n", header->status);
	print("header.version = %#x (expected: %#x)\n",
	      header->version, DRAMC_PARAM_HEADER_VERSION);
	print("header.size = %#x (expected: %#lx)\n",
	      header->size, sizeof(*dparam));
	print("header.flags = %#x\n", header->flags);
}

int initialize_dramc_param(void *blob)
{
	struct dramc_param *param = blob;
	struct dramc_param_header *hdr = &param->header;

	memset(hdr, 0, sizeof(*hdr));
	hdr->version = DRAMC_PARAM_HEADER_VERSION;
	hdr->size = sizeof(*param);
	return 0;
}
