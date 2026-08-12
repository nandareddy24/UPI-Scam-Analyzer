package com.scamshield.ai.viewmodel

import android.app.Application
import androidx.compose.runtime.State
import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.scamshield.ai.model.*
import com.scamshield.ai.repository.ScamRepository
import com.google.gson.Gson
import kotlinx.coroutines.launch
import java.io.File

class ScamViewModel(application: Application) : AndroidViewModel(application) {
    private val repository = ScamRepository(application)
    private val gson = Gson()

    private val _scanResult = mutableStateOf<ScanResponse?>(null)
    val scanResult: State<ScanResponse?> = _scanResult

    private val _history = mutableStateOf<List<HistoryItem>>(emptyList())
    val history: State<List<HistoryItem>> = _history

    private val _isLoading = mutableStateOf(false)
    val isLoading: State<Boolean> = _isLoading

    private val _error = mutableStateOf<String?>(null)
    val error: State<String?> = _error

    fun scanUpi(upi: String) = performScan { repository.scanUpi(upi) }
    fun scanPhone(phone: String) = performScan { repository.scanPhone(phone) }
    fun scanSms(sms: String) = performScan { repository.scanSms(sms) }
    fun scanUrl(url: String) = performScan { repository.scanUrl(url) }
    
    fun scanOcr(file: File) = performScan { repository.scanOcr(file) }
    fun scanQr(file: File) = performScan { repository.scanQr(file) }

    private fun performScan(call: suspend () -> retrofit2.Response<ScanResponse>) {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                val response = call()
                if (response.isSuccessful) {
                    _scanResult.value = response.body()
                } else {
                    _error.value = parseError(response)
                }
            } catch (e: Exception) {
                _error.value = "Connection error: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }

    private fun <T> parseError(response: retrofit2.Response<T>): String {
        return try {
            val errorBody = response.errorBody()?.string()
            val errorRes = gson.fromJson(errorBody, GenericResponse::class.java)
            errorRes.message
        } catch (e: Exception) {
            "Server error: ${response.code()}"
        }
    }

    fun fetchHistory() {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val response: retrofit2.Response<com.scamshield.ai.model.ScamShieldHistoryResponse> = repository.getHistory()
                if (response.isSuccessful) {
                    val data = response.body()
                    _history.value = data?.items ?: emptyList()
                } else {
                    _error.value = parseError(response)
                }
            } catch (e: Exception) {
                _error.value = "Connection error: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun reportScam(type: String, data: String, reason: String, proof: String?) {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                val response = repository.reportScam(type, data, reason, proof)
                if (response.isSuccessful) {
                    _error.value = "Report submitted successfully"
                } else {
                    _error.value = parseError(response)
                }
            } catch (e: Exception) {
                _error.value = "Connection error: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }
}
