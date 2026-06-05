package com.devsoc.freerooms.feature.buildings.ui

import androidx.annotation.DrawableRes
import com.devsoc.freerooms.feature.buildings.R

@DrawableRes
internal fun buildingImageResId(buildingId: String): Int? = when (buildingId) {
    "K-B16" -> R.drawable.k_b16
    "K-C20" -> R.drawable.k_c20
    "K-C24" -> R.drawable.k_c24
    "K-C27" -> R.drawable.k_c27
    "K-C29" -> R.drawable.k_c29
    "K-D16" -> R.drawable.k_d16
    "K-D23" -> R.drawable.k_d23
    "K-D26" -> R.drawable.k_d26
    "K-D8" -> R.drawable.k_d8
    "K-E10" -> R.drawable.k_e10
    "K-E12" -> R.drawable.k_e12
    "K-E15" -> R.drawable.k_e15
    "K-E19" -> R.drawable.k_e19
    "K-E26" -> R.drawable.k_e26
    "K-E4" -> R.drawable.k_e4
    "K-E8" -> R.drawable.k_e8
    "K-F10" -> R.drawable.k_f10
    "K-F12" -> R.drawable.k_f12
    "K-F13" -> R.drawable.k_f13
    "K-F17" -> R.drawable.k_f17
    "K-F20" -> R.drawable.k_f20
    "K-F21" -> R.drawable.k_f21
    "K-F23" -> R.drawable.k_f23
    "K-F25" -> R.drawable.k_f25
    "K-F31" -> R.drawable.k_f31
    "K-F8" -> R.drawable.k_f8
    "K-G14" -> R.drawable.k_g14
    "K-G15" -> R.drawable.k_g15
    "K-G17" -> R.drawable.k_g17
    "K-G19" -> R.drawable.k_g19
    "K-G27" -> R.drawable.k_g27
    "K-G6" -> R.drawable.k_g6
    "K-H13" -> R.drawable.k_h13
    "K-H20" -> R.drawable.k_h20
    "K-H22" -> R.drawable.k_h22
    "K-H6" -> R.drawable.k_h6
    "K-J12" -> R.drawable.k_j12
    "K-J14" -> R.drawable.k_j14
    "K-J17" -> R.drawable.k_j17
    "K-J18" -> R.drawable.k_j18
    "K-K14" -> R.drawable.k_k14
    "K-K15" -> R.drawable.k_k15
    "K-K17" -> R.drawable.k_k17
    "K-M15" -> R.drawable.k_m15
    else -> null
}
