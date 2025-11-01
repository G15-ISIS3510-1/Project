package com.example.kotlinapp.ui.feedback

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.kotlinapp.data.repository.FeedbackRepository
import kotlinx.coroutines.launch

class FeedbackViewModel(private val repository: FeedbackRepository) : ViewModel() {
    fun saveFeedback(feature: String, comment: String) {
        viewModelScope.launch {
            repository.saveFeedback(feature, comment)
        }
    }
}
