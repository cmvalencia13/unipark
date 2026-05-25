package com.unipark.android.presentation.map

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.layout
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.unipark.android.presentation.map.components.FilterChipRow
import com.unipark.android.presentation.map.components.LotDetailSheet
import com.unipark.android.presentation.map.components.LotPin
import com.unipark.android.presentation.map.components.MapCanvas
import com.unipark.android.presentation.map.components.SearchBar

@Composable
fun MapScreen(
    viewModel: MapViewModel = hiltViewModel(),
) {
    val lots by viewModel.lots.collectAsState()
    val selectedLot by viewModel.selectedLot.collectAsState()
    val filters by viewModel.filters.collectAsState()
    var selectedFilter by remember { mutableStateOf<String?>(null) }
    var containerWidth by remember { mutableStateOf(0) }
    var containerHeight by remember { mutableStateOf(0) }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .onSizeChanged { size ->
                containerWidth = size.width
                containerHeight = size.height
            },
    ) {
        // Layer 1: Map canvas
        MapCanvas(lots = lots)

        // Layer 2: Lot pins (absolutely positioned)
        lots.forEach { lot ->
            if (containerWidth > 0 && containerHeight > 0) {
                val x = (lot.xFraction * containerWidth).toInt()
                val y = (lot.yFraction * containerHeight).toInt()
                LotPin(
                    lot = lot,
                    onClick = { viewModel.selectLot(lot) },
                    modifier = Modifier.layout { measurable, constraints ->
                        val placeable = measurable.measure(constraints)
                        layout(placeable.width, placeable.height) {
                            placeable.placeRelative(x - placeable.width / 2, y - placeable.height / 2)
                        }
                    },
                )
            }
        }

        // Layer 3: Search + filters floating at top
        Column(modifier = Modifier.fillMaxWidth()) {
            Spacer(modifier = Modifier.height(8.dp))
            SearchBar(
                query = "",
                onQueryChange = { },
                onTuneClick = { },
            )
            Spacer(modifier = Modifier.height(8.dp))
            FilterChipRow(
                filters = filters,
                selectedFilter = selectedFilter,
                onFilterClick = { filter ->
                    selectedFilter = if (selectedFilter == filter) null else filter
                },
            )
        }

        // Layer 4: Detail sheet (anchored to bottom)
        LotDetailSheet(
            lot = selectedLot,
            onDismiss = { viewModel.dismissSheet() },
            modifier = Modifier.align(Alignment.BottomCenter),
        )
    }
}
