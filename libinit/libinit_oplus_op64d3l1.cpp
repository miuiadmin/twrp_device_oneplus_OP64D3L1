/*
 * Copyright (C) 2022-2025 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#include <android-base/logging.h>
#include <android-base/parseint.h>
#include <android-base/properties.h>
#define _REALLY_INCLUDE_SYS__SYSTEM_PROPERTIES_H_
#include <sys/_system_properties.h>

#include <cstring>
#include <fs_mgr.h>
#include <string>
#include <unordered_map>

using android::base::ParseInt;
using android::base::GetProperty;
using android::fs_mgr::GetKernelCmdline;

const std::unordered_map<int, std::string> kRegionSuffixMap = {
    {27, "IN"},
    {55, "RU"},
    {68, "EEA"},
    {151, ""},  // CN
    {161, "NA"},
    {167, ""},  // GLO
    {0, ""},    // Default
};

struct ModelInfo {
    const char* brand;
    const char* device;
    const char* manufacturer;
    const char* model;
    const char* base_name;
    const char* twversion;
    const char* supportSpr;
};

const std::unordered_map<int, ModelInfo> kModelInfoMap = {
    {25811, {"OnePlus", "OP64D3L1", "OnePlus", "PLY110", "PLY110", "OnePlus_Turbo_6V", "0"}},
    {0, {"OnePlus", "OP64D3L1", "OnePlus", "PLY110", "PLY110", "OnePlus_Turbo_6V", "0"}},
};

void OverrideProperty(const char* name, const char* value) {
    size_t valuelen = strlen(value);

    prop_info* pi = (prop_info*)__system_property_find(name);
    if (pi != nullptr) {
        __system_property_update(pi, value, valuelen);
    } else {
        __system_property_add(name, strlen(name), value, valuelen);
    }
}

void SetupModelProperties(const ModelInfo& info, const std::string& region) {
    std::string name = info.base_name + region;
    struct PropPair {
        const char* key;
        const char* value;
    } props[] = {
        {"ro.product.brand", info.brand},
        {"ro.product.device", info.device},
        {"ro.product.manufacturer", info.manufacturer},
        {"ro.product.model", info.model},
        {"ro.product.name", name.c_str()},
        {"ro.product.board", "volcano"},
        {"ro.board.platform", "volcano"},
        {"vendor.display.enable_spr", info.supportSpr},
        {"ro.twrp.device_version", info.twversion},
        {"ro.build.date.utc", "0"},
    };
    for (const auto& p : props) {
        OverrideProperty(p.key, p.value);
    }
}

void vendor_load_properties() {
    std::string region_buf = "0";
    GetKernelCmdline("oplus_region", &region_buf);

    int region = 0;
    if (!ParseInt(region_buf, &region)) {
        LOG(WARNING) << "Invalid oplus_region: " << region_buf << ", using default";
    }

    auto region_suffix_iter = kRegionSuffixMap.find(region);
    if (region_suffix_iter == kRegionSuffixMap.end()) {
        LOG(WARNING) << "Unknown oplus_region: " << region << ", using default";
        region_suffix_iter = kRegionSuffixMap.find(0);
    }

    int prjname = 0;
    std::string prjname_buf = GetProperty("ro.boot.prjname", "0");
    if (!ParseInt(prjname_buf, &prjname)) {
        LOG(WARNING) << "Invalid ro.boot.prjname, using Turbo 6V defaults";
    }

    auto model_info = kModelInfoMap.find(prjname);
    if (model_info == kModelInfoMap.end()) {
        LOG(ERROR) << "Unknown prjname: " << prjname << ", using Turbo 6V defaults";
        model_info = kModelInfoMap.find(0);
    }

    SetupModelProperties(model_info->second, region_suffix_iter->second);
    OverrideProperty("twrp.se.no_sb", "false");
}
