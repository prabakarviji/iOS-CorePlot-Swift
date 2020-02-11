//
//  ViewController.swift
//  Plot
//
//  Created by Prabakaran Marimuthu on 11/02/20.
//  Copyright © 2020 Prabakaran Marimuthu. All rights reserved.
//

import UIKit
import CorePlot

class ViewController: UIViewController {
    
    var plotData = [Int](repeating: 0, count: 100)
    var plot: CPTScatterPlot!
    var maxDataPoints = 100
    var frameRate = 5.0
    var alphaValue = 0.25
    var timer : Timer?
    var currentIndex: Int!
    
    @IBOutlet var hostView: CPTGraphHostingView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initPlot()
    }
    
    let xValues: [NSNumber] = [1,2,3,4,5,6,7,8,9,10]
    let yValues: [NSNumber] = [9,5,4,3]

    
    func initPlot(){
        configureHostView()
        configureGraph()
        configureChart()
//        configureLegend()
    }
    
    @objc func fireTimer(){
        let graph = self.hostView.hostedGraph
        let plot = graph?.plot(withIdentifier: "mindful-graph" as NSCopying)
        if((plot) != nil){
            if(self.plotData.count >= maxDataPoints){
                self.plotData.removeFirst()
                plot?.deleteData(inIndexRange:NSRange(location: 0, length: 1))
            }
        }
        guard let plotSpace = graph?.defaultPlotSpace as? CPTXYPlotSpace else { return }
        
        let location: NSInteger
        if self.currentIndex >= maxDataPoints {
            location = self.currentIndex - maxDataPoints+2
        } else {
            location = 0
        }
        
        let range: NSInteger
        
        if location > 0 {
            range = location-1
        } else {
            range = 0
        }
        
        let oldRange =  CPTPlotRange(locationDecimal: CPTDecimalFromDouble(Double(range)), lengthDecimal: CPTDecimalFromDouble(Double(maxDataPoints-2)))
        let newRange =  CPTPlotRange(locationDecimal: CPTDecimalFromDouble(Double(location)), lengthDecimal: CPTDecimalFromDouble(Double(maxDataPoints-2)))
        
        CPTAnimation.animate(plotSpace, property: "xRange", from: oldRange, to: newRange, duration:0.025)
        self.currentIndex += 1;
        self.plotData.append(Int.random(in: 5...10))
        plot?.insertData(at: UInt(self.plotData.count-1), numberOfRecords: 1)
    }
    
    func configureHostView(){
        hostView.allowPinchScaling = false
        self.plotData.removeAll()
        self.currentIndex = 0
    }
    
    func configureGraph(){
        let graph = CPTXYGraph(frame: hostView.bounds)
        graph.plotAreaFrame?.masksToBorder = false
        hostView.hostedGraph = graph

        // 2 - Configure the graph
        //graph.apply(CPTTheme(named: CPTThemeName.plainWhiteTheme))
        //graph.fill = CPTFill(color: CPTColor.clear())
        graph.paddingBottom = 30.0
        graph.paddingLeft = 30.0
        graph.paddingTop = 0.0
        graph.paddingRight = 0.0


        // 3 - Set up styles
        let titleStyle = CPTMutableTextStyle()
        titleStyle.color = CPTColor.black()
        titleStyle.fontName = "HelveticaNeue-Bold"
        titleStyle.fontSize = 16.0
        titleStyle.textAlignment = .center
        graph.titleTextStyle = titleStyle

        let title = "Just title"
        graph.title = title
        graph.titlePlotAreaFrameAnchor = .top
        graph.titleDisplacement = CGPoint(x: 0.0, y: -16.0)

        // 4 - Set up plot space
        let xMin = 0.0
        let xMax = 120.0
        let yMin = 0.0
        let yMax = 25.0
        guard let plotSpace = graph.defaultPlotSpace as? CPTXYPlotSpace else { return }
        plotSpace.xRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(xMin), lengthDecimal: CPTDecimalFromDouble(xMax - xMin))
        plotSpace.yRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(yMin), lengthDecimal: CPTDecimalFromDouble(yMax - yMin))
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.025, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        
    }
    
    func configureChart(){
       // 1 - Set up the plot
        plot = CPTScatterPlot()

        // 2 - Set up style
        let plotLineStile = CPTMutableLineStyle()
        plotLineStile.lineJoin = .round
        plotLineStile.lineCap = .round
        plotLineStile.lineWidth = 1
        plotLineStile.lineColor = CPTColor.red()
        plot.dataLineStyle = plotLineStile
        //plot.curvedInterpolationOption = .catmullRomChordal
        plot.interpolation = .curved
        plot.identifier = "mindful-graph" as NSCoding & NSCopying & NSObjectProtocol

        // 3- Add plots to graph
        guard let graph = hostView.hostedGraph else { return }
        plot.dataSource = (self as CPTPlotDataSource)
        plot.delegate = (self as CALayerDelegate)
        graph.add(plot, to: graph.defaultPlotSpace)
    }


}

extension ViewController: CPTScatterPlotDataSource, CPTScatterPlotDelegate {
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        // number of points
        return UInt(self.plotData.count)
    }

    func scatterPlot(_ plot: CPTScatterPlot, plotSymbolWasSelectedAtRecord idx: UInt, with event: UIEvent) {
    }

   /* func numbers(for plot: CPTPlot, field fieldEnum: UInt, recordIndexRange indexRange: NSRange) -> [Any]? {
        print("xxxxxxx")
        switch CPTScatterPlotField(rawValue: Int(fieldEnum))! {
        case .X:
            return xValues[index] as NSNumber

        case .Y:
            return yValues[indexRange] as NSNumber
        }

    } */

   /* func symbols(for plot: CPTScatterPlot, recordIndexRange indexRange: NSRange) -> [CPTPlotSymbol]? {
        return xValues
    } */

    func number(for plot: CPTPlot, field: UInt, record: UInt) -> Any? {
       switch CPTScatterPlotField(rawValue: Int(field))! {
        case .X:
            //print(NSNumber(value: Int(record) + self.currentIndex-self.plotData.count))
            return NSNumber(value: Int(record) + self.currentIndex-self.plotData.count)

        case .Y:
            print(self.plotData[Int(record)] as NSNumber)
            return self.plotData[Int(record)] as NSNumber
        }
    }
}

