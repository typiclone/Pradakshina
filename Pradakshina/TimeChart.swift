//
//  TimeChart.swift
//  Pradakshina
//
//  Created by Vasisht Muduganti on 9/17/24.
//

import Foundation
import Charts
import SwiftUI



struct TimeChart: View {
    
    var list: [LapModel]
    
    @State private var showPoints: [Bool] = []
    
    var body: some View {
        Chart {
            ForEach(Array(list.enumerated()), id: \.element.id) { index, lapChart in
                if showPoints.indices.contains(index) && showPoints[index] {
                    LineMark(
                        x: .value("Day", lapChart.day),
                        y: .value("Time", lapChart.timeInSeconds/max(lapChart.lapCount, 1))
                    )
                    .foregroundStyle(.red)
                    PointMark(
                        x: .value("Day", lapChart.day),
                        y: .value("Time", lapChart.timeInSeconds/max(lapChart.lapCount, 1))
                    )
                    .foregroundStyle(Color.primary)
                    .symbolSize(20)
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let seconds = value.as(Double.self) {
                        // Convert Double to Int for formatting time
                        Text(formatTime(seconds: Int(seconds)))
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(stroke: StrokeStyle(lineWidth: 0))
        }
        .onAppear {
            showPoints = Array(repeating: false, count: list.count)
            for index in list.indices {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.14) {
                    withAnimation {
                        showPoints[index] = true
                    }
                }
            }
        }
    }
    
    // Helper function to format seconds into minutes:seconds
    func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)  // Format time as mm:ss
    }
}
