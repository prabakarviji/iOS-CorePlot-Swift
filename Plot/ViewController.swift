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
    
    var plotData = [Double](repeating: 0.0, count: 1000)
    var plot: CPTScatterPlot!
    var maxDataPoints = 100
    var frameRate = 5.0
    var alphaValue = 0.25
    var timer : Timer?
    var currentIndex: Int!
    var timeDuration:Double = 0.1
    
    @IBOutlet var bpmText: UILabel!
    @IBOutlet var hostView: CPTGraphHostingView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initPlot()
    }
    
    func initPlot(){
        configureHostView()
        configureGraph()
        configureChart()
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
            location = self.currentIndex - maxDataPoints + 2
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
        
        CPTAnimation.animate(plotSpace, property: "xRange", from: oldRange, to: newRange, duration:0.3)
        self.currentIndex += 1;
        if(self.currentIndex % 30 == 0){
            let point = Double.random(in: 75...85)
            self.plotData.append(point)
        }
        else{
            var lastPoint:Double
            if((self.plotData.last) != nil){
                lastPoint = self.plotData.last!
            }
            else{
                lastPoint = Double.random(in: 75...85)
            }
            self.plotData.append(Double.random(in: lastPoint-0.5...lastPoint+0.5))
        }
       
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
        graph.backgroundColor = UIColor.black.cgColor

        // 2 - Configure the graph
        //graph.apply(CPTTheme(named: CPTThemeName.plainWhiteTheme))
        //graph.fill = CPTFill(color: CPTColor.clear())
        graph.paddingBottom = 40.0
        graph.paddingLeft = 40.0
        graph.paddingTop = 30.0
        graph.paddingRight = 15.0


        // 3 - Set up styles
        let titleStyle = CPTMutableTextStyle()
        titleStyle.color = CPTColor.white()
        titleStyle.fontName = "HelveticaNeue-Bold"
        titleStyle.fontSize = 16.0
        titleStyle.textAlignment = .center
        graph.titleTextStyle = titleStyle
        
        

        let title = "Real-time Graph"
        graph.title = title
        graph.titlePlotAreaFrameAnchor = .top
        graph.titleDisplacement = CGPoint(x: 0.0, y: 0.0)
        
        let axisSet = graph.axisSet as! CPTXYAxisSet
        
        let axisTextStyle = CPTMutableTextStyle()
        axisTextStyle.color = CPTColor.white()
        axisTextStyle.fontName = "HelveticaNeue-Bold"
        axisTextStyle.fontSize = 10.0
        axisTextStyle.textAlignment = .center
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineColor = CPTColor.white()
        lineStyle.lineWidth = 5
        let gridLineStyle = CPTMutableLineStyle()
        gridLineStyle.lineColor = CPTColor.gray()
        gridLineStyle.lineWidth = 0.5
       

        if let x = axisSet.xAxis {
           
            x.majorIntervalLength   = 20
            x.orthogonalPosition    = 5
            x.minorTicksPerInterval = 5
            x.labelTextStyle = axisTextStyle
            //x.majorGridLineStyle = gridLineStyle
            x.axisLineStyle = lineStyle
            x.axisConstraints = CPTConstraints(lowerOffset: 0.0)
            x.delegate = self
            
        }

        if let y = axisSet.yAxis {
         
            y.majorIntervalLength   = 5
            y.minorTicksPerInterval = 5
            y.orthogonalPosition    = 2.0
            y.labelTextStyle = axisTextStyle
            y.alternatingBandFills = [CPTFill(color: CPTColor.init(componentRed: 255, green: 255, blue: 255, alpha: 0.03)),CPTFill(color: CPTColor.black())]

            y.axisLineStyle = lineStyle
            y.axisConstraints = CPTConstraints(lowerOffset: 0.0)
            y.delegate = self
            
        }

        // 4 - Set up plot space
        let xMin = 0.0
        let xMax = 100.0
        let yMin = 65.0
        let yMax = 95.0
        guard let plotSpace = graph.defaultPlotSpace as? CPTXYPlotSpace else { return }
        plotSpace.xRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(xMin), lengthDecimal: CPTDecimalFromDouble(xMax - xMin))
        plotSpace.yRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(yMin), lengthDecimal: CPTDecimalFromDouble(yMax - yMin))
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: self.timeDuration, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        
    }
    
    func configureChart(){
       // 1 - Set up the plot
        plot = CPTScatterPlot()

        // 2 - Set up style
        let plotLineStile = CPTMutableLineStyle()
        plotLineStile.lineJoin = .round
        plotLineStile.lineCap = .round
        plotLineStile.lineWidth = 2
        plotLineStile.lineColor = CPTColor.white()
        plot.dataLineStyle = plotLineStile
        plot.curvedInterpolationOption = .catmullCustomAlpha
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

     func number(for plot: CPTPlot, field: UInt, record: UInt) -> Any? {
        
       switch CPTScatterPlotField(rawValue: Int(field))! {
        
            case .X:
                return NSNumber(value: Int(record) + self.currentIndex-self.plotData.count)

            case .Y:
                return self.plotData[Int(record)] as NSNumber
            
            default:
                return 0
        
        }
        
    }
}

