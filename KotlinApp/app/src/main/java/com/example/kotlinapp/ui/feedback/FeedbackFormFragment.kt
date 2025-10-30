package com.example.kotlinapp.ui.feedback

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.work.Constraints
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import com.example.kotlinapp.core.DatabaseModule
import com.example.kotlinapp.core.FeedbackSyncWorker
import com.example.kotlinapp.data.repository.FeedbackRepository
import com.example.kotlinapp.databinding.FragmentFeedbackFormBinding

class FeedbackFormFragment : Fragment() {

    private var _binding: FragmentFeedbackFormBinding? = null
    private val binding get() = _binding!!
    private lateinit var viewModel: FeedbackViewModel

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentFeedbackFormBinding.inflate(inflater, container, false)

        // Inicializa Room y el ViewModel
        val dao = DatabaseModule.getDatabase(requireContext()).feedbackDao()
        val repository = FeedbackRepository(dao)
        viewModel = FeedbackViewModel(repository)

        // Acción del botón de enviar feedback
        binding.btnSubmit.setOnClickListener {
            val feature = binding.etFeature.text.toString().trim()
            val comment = binding.etComment.text.toString().trim()

            if (feature.isNotEmpty() && comment.isNotEmpty()) {
                // Guarda el feedback localmente (Room)
                viewModel.saveFeedback(feature, comment)
                Toast.makeText(requireContext(), "Feedback saved locally ✅", Toast.LENGTH_SHORT).show()

                // Limpia los campos del formulario
                binding.etFeature.text.clear()
                binding.etComment.text.clear()

                // 🚀 Agenda la sincronización cuando haya Internet
                enqueueFeedbackSyncWorker()

            } else {
                Toast.makeText(requireContext(), "Please fill all fields", Toast.LENGTH_SHORT).show()
            }
        }

        return binding.root
    }

    /**
     * Encola el WorkManager que envía los feedbacks pendientes al Google Form
     * solo cuando haya conexión a Internet.
     */
    private fun enqueueFeedbackSyncWorker() {
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .build()

        val syncWork = OneTimeWorkRequestBuilder<FeedbackSyncWorker>()
            .setConstraints(constraints)
            .build()

        WorkManager.getInstance(requireContext()).enqueue(syncWork)
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
