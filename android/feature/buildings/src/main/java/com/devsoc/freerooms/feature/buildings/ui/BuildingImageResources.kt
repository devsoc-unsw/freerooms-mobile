package com.devsoc.freerooms.feature.buildings.ui

import androidx.annotation.DrawableRes
import com.devsoc.freerooms.feature.buildings.R

@DrawableRes
internal fun buildingImageResId(buildingId: String): Int? = when (buildingId) {
    "K-B16" -> R.drawable.k_b16_thumb
    "K-C20" -> R.drawable.k_c20_thumb
    "K-C24" -> R.drawable.k_c24_thumb
    "K-C27" -> R.drawable.k_c27_thumb
    "K-C29" -> R.drawable.k_c29_thumb
    "K-D16" -> R.drawable.k_d16_thumb
    "K-D23" -> R.drawable.k_d23_thumb
    "K-D26" -> R.drawable.k_d26_thumb
    "K-D8" -> R.drawable.k_d8_thumb
    "K-E10" -> R.drawable.k_e10_thumb
    "K-E12" -> R.drawable.k_e12_thumb
    "K-E15" -> R.drawable.k_e15_thumb
    "K-E19" -> R.drawable.k_e19_thumb
    "K-E26" -> R.drawable.k_e26_thumb
    "K-E4" -> R.drawable.k_e4_thumb
    "K-E8" -> R.drawable.k_e8_thumb
    "K-F10" -> R.drawable.k_f10_thumb
    "K-F12" -> R.drawable.k_f12_thumb
    "K-F13" -> R.drawable.k_f13_thumb
    "K-F17" -> R.drawable.k_f17_thumb
    "K-F20" -> R.drawable.k_f20_thumb
    "K-F21" -> R.drawable.k_f21_thumb
    "K-F23" -> R.drawable.k_f23_thumb
    "K-F25" -> R.drawable.k_f25_thumb
    "K-F31" -> R.drawable.k_f31_thumb
    "K-F8" -> R.drawable.k_f8_thumb
    "K-G14" -> R.drawable.k_g14_thumb
    "K-G15" -> R.drawable.k_g15_thumb
    "K-G17" -> R.drawable.k_g17_thumb
    "K-G19" -> R.drawable.k_g19_thumb
    "K-G27" -> R.drawable.k_g27_thumb
    "K-G6" -> R.drawable.k_g6_thumb
    "K-H13" -> R.drawable.k_h13_thumb
    "K-H20" -> R.drawable.k_h20_thumb
    "K-H22" -> R.drawable.k_h22_thumb
    "K-H6" -> R.drawable.k_h6_thumb
    "K-J12" -> R.drawable.k_j12_thumb
    "K-J14" -> R.drawable.k_j14_thumb
    "K-J17" -> R.drawable.k_j17_thumb
    "K-J18" -> R.drawable.k_j18_thumb
    "K-K14" -> R.drawable.k_k14_thumb
    "K-K15" -> R.drawable.k_k15_thumb
    "K-K17" -> R.drawable.k_k17_thumb
    "K-M15" -> R.drawable.k_m15_thumb
    else -> null
}
