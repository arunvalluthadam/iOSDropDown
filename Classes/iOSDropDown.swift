//
//  iOSDropDown.swift
//  iOSDropDown
//
///  Created by Jishnu Raj T on 26/04/18.
//  Copyright © 2018 JRiOSdev. All rights reserved.
//

import UIKit

class DropDown : UITextField{
    
    var arrow : Arrow!
    var table : UITableView!
    var shadow : UIView!
    
    public fileprivate(set) var selectedIndex: Int?
    
    //  Configurations
    
    public var rowHeight: CGFloat = 50
    public var rowBackgroundColor: UIColor = .white
    public var selectedRowColor: UIColor = .cyan
    public var hideOptionsWhenSelect = true
    public var isSearchEnable: Bool = true {
        didSet{
            addGesture()
        }
    }
    //Variables
    fileprivate  var tableheightX: CGFloat = 100
    fileprivate  var dataArray = [String]()
    var optionArray = [String]() {
        didSet{
            self.dataArray = self.optionArray
        }
    }
    var searchText = String() {
        didSet{
            if searchText == "" {
                self.dataArray = self.optionArray
            }else{
                self.dataArray = optionArray.filter {
                    return $0.range(of: searchText, options: .caseInsensitive) != nil
                }
            }
            reSizeTable()
            selectedIndex = nil
            self.table.reloadData()
        }
    }
    public var arrowPadding: CGFloat = 7.0 {
        didSet{
            let size = arrow.superview!.frame.size.width-(arrowPadding*2)
            arrow.frame = CGRect(x: arrowPadding, y: arrowPadding, width: size, height: size)
        }
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        setupUI()
        self.delegate = self
    }
    
    //MARK: IBInspectable
    
    @IBInspectable var borderColor: UIColor =  UIColor.lightGray {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    @IBInspectable var tableHieght: CGFloat = 50{
        didSet {
            
        }
    }
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 5.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    //MARK: Closures
    fileprivate var didSelectCompletion: (String, Int) -> () = {selectedText, index in }
    fileprivate var TableWillAppearCompletion: () -> () = { }
    fileprivate var TableDidAppearCompletion: () -> () = { }
    fileprivate var TableWillDisappearCompletion: () -> () = { }
    fileprivate var TableDidDisappearCompletion: () -> () = { }
    
    func setupUI () {
        
        let size = self.frame.height
        let rightView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: size - 2*arrowPadding, height: size))
        let arrowContainerView = UIView(frame: CGRect(x: self.bounds.maxX - size,
                                                      y: 0,
                                                      width: size,
                                                      height: size))
        arrowContainerView.isUserInteractionEnabled = true
        self.rightView = rightView
        self.rightViewMode = .always
        self.addSubview(arrowContainerView)
        
        arrow = Arrow(origin: CGPoint(x: arrowPadding,
                                      y: arrowPadding),
                      size: arrowContainerView.frame.width - (arrowPadding*2))
        arrowContainerView.addSubview(arrow)
        addGesture()
        
        
    }
    fileprivate func addGesture (){
        let gesture =  UITapGestureRecognizer(target: self, action:  #selector(touchAction))
        if isSearchEnable{
            self.rightView?.addGestureRecognizer(gesture)
        }else{
            self.addGestureRecognizer(gesture)
        }
        
    }
    
    public func showList() {
        
        TableWillAppearCompletion()
        if tableHieght > rowHeight * CGFloat( dataArray.count) {
            self.tableheightX = rowHeight * CGFloat(dataArray.count)
        }else{
            self.tableheightX = tableHieght
        }
        table = UITableView(frame: CGRect(x: self.frame.minX,
                                          y: self.frame.minY,
                                          width: self.frame.width,
                                          height: self.frame.height))
        shadow = UIView(frame: CGRect(x: self.frame.minX,
                                      y: self.frame.minY,
                                      width: self.frame.width,
                                      height: self.frame.height))
        shadow.backgroundColor = .clear
        
        table.dataSource = self
        table.delegate = self
        table.alpha = 0
        table.separatorStyle = .none
        table.layer.cornerRadius = 3
        table.backgroundColor = rowBackgroundColor
        table.rowHeight = rowHeight
        
        self.superview?.insertSubview(shadow, belowSubview: self)
        self.superview?.insertSubview(table, belowSubview: self)
        self.isSelected = true
        UIView.animate(withDuration: 0.9,
                       delay: 0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseInOut,
                       animations: { () -> Void in
                        
                        self.table.frame = CGRect(x: self.frame.minX,
                                                  y: self.frame.maxY+5,
                                                  width: self.frame.width,
                                                  height: self.tableheightX)
                        
                        self.table.alpha = 1
                        self.shadow.frame = self.table.frame
                        self.shadow.dropShadow()
                        self.arrow.position = .up
                        
        },
                       completion: { (finish) -> Void in
                        
        })
        
    }
    
    
    public func hideList() {
        
        TableWillDisappearCompletion()
        UIView.animate(withDuration: 1.0,
                       delay: 0.4,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseInOut,
                       animations: { () -> Void in
                        self.table.frame = CGRect(x: self.frame.minX,
                                                  y: self.frame.minY,
                                                  width: self.frame.width,
                                                  height: 0)
                        self.shadow.alpha = 0
                        self.shadow.frame = self.table.frame
                        self.arrow.position = .down
        },
                       completion: { (didFinish) -> Void in
                        
                        self.shadow.removeFromSuperview()
                        self.table.removeFromSuperview()
                        self.isSelected = false
                        self.TableDidDisappearCompletion()
        })
    }
    
    @objc func touchAction() {
        
        isSelected ?  hideList() : showList()
    }
    func reSizeTable() {
        if tableHieght > rowHeight * CGFloat( dataArray.count) {
            self.tableheightX = rowHeight * CGFloat(dataArray.count)
        }else{
            self.tableheightX = tableHieght
        }
        UIView.animate(withDuration: 0.2,
                       delay: 0.1,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseInOut,
                       animations: { () -> Void in
                        self.table.frame = CGRect(x: self.frame.minX,
                                                  y: self.frame.maxY+5,
                                                  width: self.frame.width,
                                                  height: self.tableheightX)
                        
                        
        },
                       completion: { (didFinish) -> Void in
                        self.shadow.layer.shadowPath = UIBezierPath(rect: self.table.bounds).cgPath
                        
        })
    }
    
    //MARK: Actions Methods
    public func didSelect(completion: @escaping (_ selectedText: String, _ index: Int) -> ()) {
        didSelectCompletion = completion
    }
    
    public func tableWillAppear(completion: @escaping () -> ()) {
        TableWillAppearCompletion = completion
    }
    
    public func tableDidAppear(completion: @escaping () -> ()) {
        TableDidAppearCompletion = completion
    }
    
    public func tableWillDisappear(completion: @escaping () -> ()) {
        TableWillDisappearCompletion = completion
    }
    
    public func tableDidDisappear(completion: @escaping () -> ()) {
        TableDidDisappearCompletion = completion
    }
    
}

//MARK: UITextFieldDelegate
extension DropDown : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        superview?.endEditing(true)
        return false
    }
    func  textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        self.selectedIndex = nil
        self.dataArray = self.optionArray
        touchAction()
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return isSearchEnable
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string != "" {
            self.searchText = self.text! + string
        }else{
            let subText = self.text?.dropLast()
            self.searchText = String(subText!)
        }
        if !isSelected {
            showList()
        }
        return true;
    }
    
}
///MARK: UITableViewDataSource
extension DropDown: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "DropDownCell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        if indexPath.row != selectedIndex{
            cell!.backgroundColor = rowBackgroundColor
        }else {
            cell?.backgroundColor = selectedRowColor
        }
        
        cell!.textLabel!.text = "\(dataArray[indexPath.row])"
        cell!.accessoryType = indexPath.row == selectedIndex ? .checkmark : .none
        cell!.selectionStyle = .none
        
        return cell!
    }
}
//MARK: UITableViewDelegate
extension DropDown: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = (indexPath as NSIndexPath).row
        let selectedText = self.dataArray[self.selectedIndex!]
        tableView.cellForRow(at: indexPath)?.alpha = 0
        UIView.animate(withDuration: 0.5,
                       animations: { () -> Void in
                        tableView.cellForRow(at: indexPath)?.alpha = 1.0
                        tableView.cellForRow(at: indexPath)?.backgroundColor = self.selectedRowColor
        } ,
                       completion: { (didFinish) -> Void in
                        self.text = "\(selectedText)"
                        
                        tableView.reloadData()
        })
        if hideOptionsWhenSelect {
            touchAction()
            self.endEditing(true)
        }
        if let selected = optionArray.index(where: {$0 == selectedText}) {
            didSelectCompletion(selectedText, selected)
        }
        
    }
}






//MARK: Arrow

enum Position {
    case left
    case down
    case right
    case up
}

class Arrow: UIView {
    
    var position: Position = .down {
        didSet{
            switch position {
            case .left:
                self.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
                break
                
            case .down:
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi*2)
                break
                
            case .right:
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                break
                
            case .up:
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                break
            }
        }
    }
    
    init(origin: CGPoint, size: CGFloat) {
        super.init(frame: CGRect(x: origin.x, y: origin.y, width: size, height: size))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        // Get size
        let size = self.layer.frame.width
        
        // Create path
        let bezierPath = UIBezierPath()
        
        // Draw points
        let qSize = size/4
        
        bezierPath.move(to: CGPoint(x: 0, y: qSize))
        bezierPath.addLine(to: CGPoint(x: size, y: qSize))
        bezierPath.addLine(to: CGPoint(x: size/2, y: qSize*3))
        bezierPath.addLine(to: CGPoint(x: 0, y: qSize))
        bezierPath.close()
        
        // Mask to path
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        self.layer.mask = shapeLayer
    }
}

extension UIView {
    
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 2
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    
}
