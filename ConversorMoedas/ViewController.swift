//
//  ViewController.swift
//  ConversorMoedas
//
//  Created by Rafael Farias on 13/02/18.
//  Copyright © 2018 Rafael Farias. All rights reserved.
//

import UIKit

class ViewController: UIViewController{
    
    //MARK: Propriedades
    
    //Struct base para armazenar os dados da API
    struct Currency: Decodable{
        let base: String
        let date: String
        var rates: [String : Double]
    }
    
    
    var brl : Currency?
    var baseRate : Double = 1.0
    
    var roundButton = UIButton()
    
    //Array onde ficarão as moedas listadas no UIPickerView
    var arrayCurrency : [String] = []
    
    
    //MARK: Outlets
    @IBOutlet weak var tfValue: UITextField!
    @IBOutlet weak var tvCurrencies: UITableView!
    @IBOutlet weak var tfCurrencies: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //PickerView criado para listar as moedas disponíveis. Será atrelado a um textview
        let pvCurrencySymbol = UIPickerView()
        
        //Atribuindo o pickerview ao textView
        tfCurrencies.inputView = pvCurrencySymbol
        
        //Moeda Padrao para conversdao
        tfCurrencies.text = "BRL"
        
        
        tfValue.text = "1.0"
        
        //Tirando a "faixa cinza" do tableView via código
        tvCurrencies.allowsSelection = false
        
        //Desabilitando a visualização da barra de scroll
        tvCurrencies.showsVerticalScrollIndicator = false
        
        //Adotando os protocolos implementados
        tvCurrencies.dataSource = self
        tfValue.delegate = self
        pvCurrencySymbol.delegate = self
        pvCurrencySymbol.dataSource = self
        
        
        tfValue.textAlignment = .center
        tfValue.keyboardType = .numbersAndPunctuation
        
        //Comentado até encontrar a solução para mudança de posicao
        //Botão arredondado flutuante
//        self.roundButton = UIButton(type: .custom)
//        self.roundButton.setTitleColor(UIColor.orange, for: .normal)
//        self.roundButton.addTarget(self, action: #selector(ButtonClick(_:)), for: UIControlEvents.touchUpInside)
//        self.view.addSubview(roundButton)
        
        
        //Método para recuperar os dados da API
        fetchData()
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Memory Alert")
    }
    //MARK: Actions
    @IBAction func btnConvert(_ sender: UIButton) {
        
        //Convertendo o valor do textField para double - Será usado em na multiplicacao no método fetchData()
        if let iGetString = tfValue.text{
            if let isDouble = Double(iGetString){
                baseRate = isDouble
            }
        }
        self.view.endEditing(true)
        
        fetchData()
    }
    
    //MARK: Métodos Próprios
    
    //Método para criar o botão arredondado Botao
//    override func viewWillLayoutSubviews() {
//        
//        roundButton.layer.cornerRadius = roundButton.layer.frame.size.width/2
//        roundButton.backgroundColor = hexStringToUIColor(hex: "#00ADB5")
//        roundButton.clipsToBounds = true
//        roundButton.setImage(UIImage(named:"edit"), for: .normal)
//        roundButton.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            roundButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -3),
//            roundButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -53),
//            roundButton.widthAnchor.constraint(equalToConstant: 50),
//            roundButton.heightAnchor.constraint(equalToConstant: 50)])
//    }
    
    /** Action do botão arredondado*/
    
//    @IBAction func ButtonClick(_ sender: UIButton){
//
//        //Habilita/Desabilita a edição do tableview
//        tvCurrencies.isEditing = !tvCurrencies.isEditing
//
//        if tvCurrencies.isEditing{
//            self.tvCurrencies.reloadData()
//        }
//
//    }
    //Fim do Método para criar o botão arredondado Botao
    
    
    //Método para recuperar os dados da API
    func fetchData(){
        let enderecoURL = "https://api.fixer.io/latest?base=\(String(describing: tfCurrencies.text!))&symbols=USD,EUR,GBP,AUD,NZD,SGD,CAD,BRL,JPY,HKD"
        let url = URL(string: enderecoURL)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error == nil {
                
                do{
                    self.brl = try JSONDecoder().decode(Currency.self, from: data!)
                    
                    DispatchQueue.main.async {
                        for (key, _) in  self.brl!.rates{
                            self.arrayCurrency.append(key)
                            //print("ARRAY AQUI!!!!\(self.arrayCurrency)")
                            
                        }
                        
                        
                        self.tvCurrencies.reloadData()
                    }
                    //print("ARRAY AQUI!!!!\(self.arrayCurrency)")
                    
                }catch{
                    print("Erros ao fazer o Parse da API: \(String(describing: error))")
                }
                
                
            }else {
                print("Erros ao obter dados da API: \(String(describing: error))")
            }
            }.resume()
    }
    
    //Transforma um código HEX de cores em um objeto UIColor
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    //MARK: Métodos de UIResponder
    //Permitir que os objetos de interação com o usuário percam o foco do teclado
    override var canBecomeFirstResponder: Bool{
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.becomeFirstResponder()
    }
    
}

//MARK: Extensions

extension ViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let currencyFetched = brl {
            return currencyFetched.rates.count
        }
        
        return 0
    }
    
    //Método que alimenta a tableview
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        
        
        if let currencyFetched = brl {

            cell.textLabel?.text = Array(currencyFetched.rates.keys)[indexPath.row]
            let selectedRate = baseRate * Double(Array(currencyFetched.rates.values)[indexPath.row])
            cell.detailTextLabel?.text = "\(selectedRate)"
            cell.contentView.backgroundColor = hexStringToUIColor(hex: "#393E46")
            cell.textLabel?.textColor = hexStringToUIColor(hex: "#EEEEEE")
            return cell
        }
        return UITableViewCell()
    }
    
    //Habilitando a troca de linhas na tableview
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    //Método que move as linhas
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
       
        
        if let currencyFetched = brl {
            
            var arrayDic = Array(currencyFetched.rates)
            
            let item = arrayDic[sourceIndexPath.row]
            arrayDic.remove(at: sourceIndexPath.row)
            arrayDic.insert(item, at: destinationIndexPath.row)
            
            //Removendo apenas o array de structs
            brl?.rates.removeAll()
            
            print()
            print()
            print(arrayDic)
            print()
            print()
            
            //Realimentando o array de structs com o array na nova ordem
            for (key, value) in arrayDic{
                brl!.rates[key] = value
            }
            
        }
        
    }
    

    
}

//MARK: Extensao para PickerView
extension ViewController : UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        tfCurrencies.text = arrayCurrency[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        //Alterando cor da fonte e de fundo do pickerview
        let attributedString = NSAttributedString(string: arrayCurrency[row], attributes: [NSAttributedStringKey.foregroundColor : hexStringToUIColor(hex: "#EEEEEE"), NSAttributedStringKey.backgroundColor : hexStringToUIColor(hex: "#393E46")])
        return attributedString
    }
    
}

extension ViewController : UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrayCurrency.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerView.backgroundColor = hexStringToUIColor(hex: "#393E46")
        return arrayCurrency[row]
    }
    
    
}
//
//MARK: Extensao para adocao do protocolo UITextFieldDelegate
extension ViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

