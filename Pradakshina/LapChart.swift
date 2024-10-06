//
//  LapChart.swift
//  Pradakshina
//
//  Created by Vasisht Muduganti on 9/17/24.
//

import Foundation
import Charts
import SwiftUI

struct LapModel: Identifiable {
    var id = UUID()
    let day: String
    let timeInSeconds: Int
    let lapCount: Int// Store time in seconds
}

struct LapChart: View {
    
    var list:[LapModel]
    
    @State private var showPoints: [Bool] = []
    
    var body: some View {
        Chart {
            ForEach(Array(list.enumerated()), id: \.element.id) { index, lapChart in
                if showPoints.indices.contains(index) && showPoints[index] {
                    LineMark(
                        x: .value("Day", lapChart.day),
                        y: .value("LapCount", lapChart.lapCount)
                    )
                    .foregroundStyle(.red)
                    PointMark(
                        x: .value("Day", lapChart.day),
                        y: .value("LapCount", lapChart.lapCount)
                    )
                    .foregroundStyle(Color.primary)
                    .symbolSize(20)
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartYAxis {
        AxisMarks(stroke: StrokeStyle(lineWidth: 0))
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
}
