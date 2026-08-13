package com.scamshield.ai.model

import com.google.gson.annotations.SerializedName

data class User(
    val id: Int,
    val name: String,
    val email: String,
    @SerializedName("is_admin") val isAdmin: Boolean
)

data class LoginResponse(
    val status: String,
    val message: String,
    val token: String?,
    val user: User?
)

data class RegisterResponse(
    val status: String,
    val message: String,
    val user: User?
)

data class ScanRequest(
    val upi: String? = null,
    val phone: String? = null,
    val sms: String? = null,
    val url: String? = null
)

data class ScanResponse(
    val status: String?,
    val result: String,
    val score: Int,
    val reason: String,
    val advice: String?,
    val confidence: Int?
)

data class ScamShieldHistoryResponse(
    val status: String,
    val items: List<HistoryItem>
)

data class HistoryItem(
    val type: String,
    val data: String,
    val score: Int,
    val result: String,
    val date: String
)

data class ReportRequest(
    val type: String,
    val data: String,
    val reason: String,
    val proof: String? = null
)

data class GenericResponse(
    val status: String,
    val message: String
)

data class AdminReportItem(
    val id: Int,
    val type: String,
    @SerializedName("input_data") val inputData: String,
    val reason: String,
    val status: String,
    @SerializedName("created_at") val createdAt: String,
    @SerializedName("proof_data") val proofData: String? = null
)

data class BlacklistItem(
    val id: Int,
    val data: String,
    val type: String,
    val reason: String
)

data class AddBlacklistRequest(
    val data: String,
    val type: String,
    val reason: String
)
