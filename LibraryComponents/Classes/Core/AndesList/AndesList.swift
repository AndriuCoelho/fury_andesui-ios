//
//  AndesList.swift
//  AndesUI
//
//  Created by Jonathan Alonso Pinto on 16/10/20.
//

import Foundation

@objc public class AndesList: UIView {

    /// Set the delegate to use own methods
    @objc public weak var delegate: AndesListDelegate?

    /// Set the dataSource to use own methods
    @objc public weak var dataSource: AndesListDataSource?

    /// Set the separator style, default value .none
    @objc public var separatorStyle: AndesSeparatorStyle = .none

    /// Set the list type, default value simple
    @IBInspectable public var listType: String {
        set(val) {
            self.listAllowedType = AndesCellType.checkValidEnum(property: listType, key: val)
        }
        get {
            return self.listAllowedType.toString()
        }
    }

    @objc public func reloadData() {
        self.tableView.reloadData()
    }

    private var tableView: UITableView = UITableView()
    private lazy var internalDataSource: AndesListTableViewDataSource? = {
        let internalDataSource = AndesListTableViewDataSource(listProtocol: self)
        return internalDataSource
    }()
    private lazy weak var internalDelegate: AndesListTableViewDelegate? = {
        let internalDelegate = AndesListTableViewDelegate(listProtocol: self)
        return internalDelegate
    }()
    private var listAllowedType: AndesCellType = .simple

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    public init(type: String) {
        super.init(frame: .zero)
        listAllowedType = AndesCellType.checkValidEnum(property: type, key: type)
        setup()
    }

    /// Setup delegates and register UITableViewCell on the UITableView
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        self.tableView.delegate = internalDelegate
        self.tableView.dataSource = internalDataSource
        self.tableView.separatorStyle = .none
        self.tableView.separatorInset.left = UIScreen.main.bounds.width
        tableView.register(UINib(nibName: "AndesListSimpleViewCell",
                                 bundle: AndesBundle.bundle()),
                           forCellReuseIdentifier: "AndesListSimpleViewCell")
        tableView.register(UINib(nibName: "AndesListChevronViewCell",
                                 bundle: AndesBundle.bundle()),
                           forCellReuseIdentifier: "AndesListChevronViewCell")
        drawContentView()
    }

    private func drawContentView() {
        addSubview(self.tableView)
        self.tableView.pinToSuperview()
    }
}

/// Use (UITableViewDelegate and UITableViewDatasource) in a independent protocol
extension AndesList: AndesListProtocol {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.numberOfSections(self) ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.andesList(self, numberOfRowsInSection: section) ?? 0
    }

    func cellForRowAt(indexPath: IndexPath) -> AndesListCell {
        guard let customCell = dataSource?.andesList(self, cellForRowAt: indexPath), customCell.type == listAllowedType else {
            fatalError("Cell type not allowed, should be \(listAllowedType.toString()) type")
        }
        return customCell
    }

    func getSeparatorStyle() -> AndesSeparatorStyle {
        return self.separatorStyle
    }

    func didSelectRowAt(indexPath: IndexPath) {
        self.delegate?.andesList?(self, didSelectRowAt: indexPath)
    }
}