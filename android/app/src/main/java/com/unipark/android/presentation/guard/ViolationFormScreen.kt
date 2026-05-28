package com.unipark.android.presentation.guard

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.PhotoCamera
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.unipark.android.presentation.UniParkCardRadius
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.UUID

@Composable
fun ViolationFormScreen(
    vehicleId: UUID = UUID(0, 2),
    lotId: UUID = UUID(0, 1),
    viewModel: ViolationFormViewModel = hiltViewModel(),
) {
    val state by viewModel.state.collectAsState()
    val infractions by viewModel.infractions.collectAsState()

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        item {
            Text("Infracciones", style = MaterialTheme.typography.headlineSmall)
        }
        item {
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(UniParkCardRadius),
                elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(14.dp),
                ) {
                    Text("Registrar multa", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
                    OutlinedTextField(
                        value = state.plate,
                        onValueChange = viewModel::setPlate,
                        modifier = Modifier.fillMaxWidth(),
                        label = { Text("Placa") },
                        singleLine = true,
                    )
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        listOf("Lote A", "Lote B", "Lote C").forEach { lot ->
                            FilterChip(
                                selected = state.selectedLotName == lot,
                                onClick = { viewModel.selectLot(lot) },
                                label = { Text(lot) },
                            )
                        }
                    }
                    OutlinedTextField(
                        value = state.reason,
                        onValueChange = viewModel::setReason,
                        modifier = Modifier.fillMaxWidth(),
                        minLines = 4,
                        label = { Text("Motivo") },
                        placeholder = { Text("Mal parqueado, lote incorrecto, choque no reportado...") },
                    )
                    OutlinedButton(onClick = { }, shape = RoundedCornerShape(UniParkCardRadius)) {
                        Icon(Icons.Outlined.PhotoCamera, contentDescription = null)
                        Text("Agregar foto")
                    }
                    Button(
                        onClick = { viewModel.submit(vehicleId, lotId) },
                        enabled = state.plate.isNotBlank() && state.reason.isNotBlank(),
                        shape = RoundedCornerShape(UniParkCardRadius),
                        modifier = Modifier.fillMaxWidth(),
                    ) {
                        Text("Registrar infraccion")
                    }
                    state.error?.let { Text(it, color = MaterialTheme.colorScheme.error) }
                }
            }
        }
        item {
            Text("Registro reciente", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
        }
        items(infractions) { record ->
            InfractionCard(record)
        }
    }

    if (state.saved) {
        AlertDialog(
            onDismissRequest = viewModel::clearSuccess,
            confirmButton = {
                TextButton(onClick = viewModel::clearSuccess) {
                    Text("Listo")
                }
            },
            title = { Text("Infraccion registrada") },
            text = { Text("La multa fue agregada al registro y se intentara sincronizar con el backend.") },
        )
    }
}

@Composable
private fun InfractionCard(record: InfractionRecord) {
    val formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")
        .withZone(ZoneId.systemDefault())
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(UniParkCardRadius),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(6.dp),
        ) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                Text(record.plate, fontWeight = FontWeight.Bold, style = MaterialTheme.typography.titleMedium)
                Text(record.status, color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.Bold)
            }
            Text("${record.lotName} • ${formatter.format(record.createdAt)}", color = MaterialTheme.colorScheme.onSurfaceVariant)
            Text(record.reason)
            if (record.photoUri == null) {
                Text("Sin foto adjunta", color = MaterialTheme.colorScheme.onSurfaceVariant, style = MaterialTheme.typography.labelSmall)
            }
        }
    }
}
