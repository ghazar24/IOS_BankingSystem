//
//  MainViewController.swift
//  IOS-FinalProject-LSBank
//
//  Created by user203175 on 10/19/21.
//

import UIKit

class MainViewController: UIViewController, BalanceRefresh, UITableViewDelegate, UITableViewDataSource {
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var vBtnWithdraw : UIView!
    @IBOutlet weak var vBtnDeposit : UIView!
    @IBOutlet weak var vBtnTransfer : UIView!
    
    @IBOutlet weak var lblUsername : UILabel!
    @IBOutlet weak var lblBalance : UILabel!
    
    @IBOutlet weak var btnRefreshBalance : UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initialize()
        
        lblUsername.text = "Hi \(LoginViewController.account!.firstName)"
        
        refreshBalance()
    }
    
    private func initialize(){
        customizeView()
        
        tableView.register(TransactionTableViewCell.nib(), forCellReuseIdentifier: TransactionTableViewCell.identifier)
        
        
        
        
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
    }
    
    private func customizeView() {
        vBtnWithdraw.setLayerCornerRadius(MyAppDefaults.LayerCornerRadius.button)
        vBtnDeposit.setLayerCornerRadius(MyAppDefaults.LayerCornerRadius.button)
        vBtnTransfer.setLayerCornerRadius(MyAppDefaults.LayerCornerRadius.button)
    }
    
    
    @IBAction func btnLogOff(_ sender: Any) {
        
        let btnYes = Dialog.DialogButton(title: "Yes", style: .default, handler: {action in
            self.navigationController?.popViewController(animated: true)
        })
        let btnNo = Dialog.DialogButton(title: "No", style: .destructive, handler: nil)
        
        Dialog.show(view: self, title: "Login off", message: "\(LoginViewController.account!.firstName), are you sure you want to leave?", style: .actionSheet, completion: nil, presentAnimated: true, buttons: btnYes, btnNo)
        
        
    }
    
    
    
    func refreshBalanceSuccess(httpStatusCode : Int, response : [String:Any] ){
        
        DispatchQueue.main.async {
            self.btnRefreshBalance.isEnabled = true
            self.lblBalance.text = "?"
        }
        
        if httpStatusCode == 200 {
            
            if let accountBalance = AccountsBalance.decode(json: response){
                
                DispatchQueue.main.async {
                    self.lblBalance.text = "CAD$ " + accountBalance.balance.formatAsCurrency()
                }
                
            }
        } else {
            DispatchQueue.main.async {
                Toast.show(view: self, title: "Something went wrong!", message: "Error parsing data received from server! Try again!")
            }
        }
        
    }
    
    
    func refreshBalanceFail( httpStatusCode : Int, message : String ){
        
        DispatchQueue.main.async {
            self.lblBalance.text = ""
            self.btnRefreshBalance.isEnabled = true
            Toast.show(view: self, title: "Ooops!", message: message)
        }
        
    }
    
    
    
    func refreshBalance() {
        
        lblBalance.text = "wait..."
        
        LSBankAPI.accountBalance(token: LoginViewController.token, successHandler: refreshBalanceSuccess, failHandler: refreshBalanceFail)
        
    }
    
    @IBAction func btnRefreshBalanceTouchUp(_ sender : Any? ) {
        
        btnRefreshBalance.isEnabled = false
        refreshBalance()
        
    }
    
    @IBAction func btnPayeeTouchUp(_ sender : Any? ) {
        
        performSegue(withIdentifier: Segue.toPayeesView, sender: nil)
        
    }
    
    @IBAction func btnSendMoneyTouchUp(_ sender : Any? ){
        
        if Payee.all(context: self.context).count == 0 {
            Toast.ok(view: self, title: "No payees", message: "Please, set your payees list before sending money!")
            return
        }
        
        
        performSegue(withIdentifier: Segue.toSendMoneyView, sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Segue.toSendMoneyView {
            
            (segue.destination as! SendMoneyViewController).payeeList = Payee.allByFirstName(context: self.context)
            (segue.destination as! SendMoneyViewController).delegate = self
            
            
        }
        
    }
    
    func balanceRefresh() {
        // BalanceRefresh protocol stub
        self.refreshBalance()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier , for: indexPath) as!
        TransactionTableViewCell
        
        cell.setCellContent(accountHolder: "Alex", dateTime: "2021/12/17", amount: 1801, credit: true, message: "test")
        
        return cell
        
    }
    
    
    
}
