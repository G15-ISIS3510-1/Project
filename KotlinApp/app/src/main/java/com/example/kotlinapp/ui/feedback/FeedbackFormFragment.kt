package com.example.kotlinapp.ui.feedback

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.work.*
import com.example.kotlinapp.core.DatabaseModule
import com.example.kotlinapp.core.FeedbackSyncWorker
import com.example.kotlinapp.data.repository.FeedbackRepository
import com.example.kotlinapp.databinding.FragmentFeedbackFormBinding
import com.google.android.material.snackbar.Snackbar

class FeedbackFormFragment : Fragment() {

    private var _binding: FragmentFeedbackFormBinding? = null
    private val binding get() = _binding!!

    private val dao by lazy { DatabaseModule.getDatabase(requireContext()).feedbackDao() }
    private val repository by lazy { FeedbackRepository(dao) }
    private val viewModel by lazy { FeedbackViewModel(repository) }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentFeedbackFormBinding.inflate(inflater, container, false)

        binding.btnSubmit.setOnClickListener {
            val feature = binding.etFeature.text.toString().trim()
            val comment = binding.etComment.text.toString().trim()

            if (feature.isNotEmpty() && comment.isNotEmpty()) {
                binding.btnSubmit.isEnabled = false
                viewModel.saveFeedback(
                    feature,
                    comment,
                    onSuccess = {
                        binding.etFeature.text.clear()
                        binding.etComment.text.clear()
                        binding.btnSubmit.isEnabled = true
                        showSnack("✅ Feedback saved locally")
                        enqueueFeedbackSyncWorker()
                    },
                    onError = {
                        binding.btnSubmit.isEnabled = true
                        showSnack("❌ Error saving feedback: ${it.message}")
                    }
                )
            } else {
                showSnack("Please fill all fields")
            }
        }

        return binding.root
    }

    private fun enqueueFeedbackSyncWorker() {
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .build()

        val syncWork = OneTimeWorkRequestBuilder<FeedbackSyncWorker>()
            .setConstraints(constraints)
            .build()

        WorkManager.getInstance(requireContext()).enqueueUniqueWork(
            "FeedbackSync",
            ExistingWorkPolicy.KEEP, // ✅ evita duplicados
            syncWork
        )
    }

    private fun showSnack(message: String) {
        Snackbar.make(binding.root, message, Snackbar.LENGTH_LONG).show()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
