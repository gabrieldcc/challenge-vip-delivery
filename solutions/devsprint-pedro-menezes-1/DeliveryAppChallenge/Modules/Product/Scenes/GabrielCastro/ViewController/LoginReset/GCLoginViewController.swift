import UIKit

final class GCLoginViewController: UIViewController {
    
    //MARK: - Vars
    private var errorInLogin = false
    private var showPassword = true
    private let viewModel = GCLoginViewModel()
    private let gcLoginCoordinator = GCLoginCoordinator()
    private let badNetworkLayer = BadNetworkLayer()
    private let gcAlert = GCAlert()
    
    @IBOutlet weak var heightLabelError: NSLayoutConstraint!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var showPasswordButton: UIButton!
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //verifyLogin()
        loginDefault()
        setupView()
        validateButton()
    }
    
    private func validateLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        let parameters: [String: String] = ["email": email, "password": password]
        badNetworkLayer.login(self, parameters: parameters) { session in
            if let session = session {
                self.handleSuccessValidateLogin(session: session)
            } else {
                self.showRequestError()
            }
        }
    }
    
    private func handleSuccessValidateLogin(session: Session) {
        self.gcLoginCoordinator.showViewController(vc: HomeViewController())
        UserDefaultsManager.UserInfos.shared.save(session: session, user: nil)
    }
    
    private func loginDefault() {
#if DEBUG
        emailTextField.text = "clean.code@devpass.com"
        passwordTextField.text = "111111"
#endif
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
//    private func verifyLogin() {
//        if let _ = UserDefaultsManager.UserInfos.shared.readSesion() {
//            gcLoginCoordinator.showViewController(vc: HomeViewController())
//        }
//    }
    
    func showRequestError() {
        self.setErrorLogin("E-mail ou senha incorretos")
        gcAlert.showAlertMessage(title: "Ops..", message: "Houve um problema, tente novamente mais tarde.", targetVC: self)
    }
    
        
    private func setupPasswordButtonImage() {
        let imageName = showPassword ? "eye.slash" : "eye"
        let image = UIImage.init(systemName: imageName)?.withRenderingMode(.alwaysTemplate)
        showPasswordButton.setImage(image, for: .normal)
    }
    
}

// MARK: - Comportamentos de layout
private extension GCLoginViewController {
    
    func setupView() {
        setupLoginButton()
        showPasswordButton.tintColor = .lightGray
        setupCreateAccountButton()
        setupTextFields()
        gestureDidClickView()
        heightLabelError.constant = 0
        validateButton()
    }
    
    func setupLoginButton() {
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
        loginButton.backgroundColor = .blue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.isEnabled = true
    }
    
    func setupCreateAccountButton() {
        createAccountButton.layer.cornerRadius = createAccountButton.frame.height / 2
        createAccountButton.layer.borderWidth = 1
        createAccountButton.layer.borderColor = UIColor.blue.cgColor
        createAccountButton.setTitleColor(.blue, for: .normal)
        createAccountButton.backgroundColor = .white
    }
    
    func setupTextFields() {
        emailTextField.setDefaultColor()
        passwordTextField.setDefaultColor()
    }
    
    func gestureDidClickView() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didClickView))
        view.addGestureRecognizer(gesture)
        view.isUserInteractionEnabled = true
    }
    
    func setErrorLogin(_ message: String) {
        errorInLogin = true
        heightLabelError.constant = 20
        errorLabel.text = message
        emailTextField.setErrorColor()
        passwordTextField.setErrorColor()
    }
    
    func resetErrorLogin(_ textField: UITextField) {
        heightLabelError.constant = 0
        if textField == emailTextField {
            emailTextField.setEditingColor()
            passwordTextField.setDefaultColor()
        } else {
            emailTextField.setDefaultColor()
            passwordTextField.setDefaultColor()
        }
    }
    
    @objc func didClickView() {
        view.endEditing(true)
    }
    
}

private extension GCLoginViewController {
    
    func validateButton() {
        guard let email = emailTextField.text else { return }
        if viewModel.validateEmail(textField: email) {
            self.enableButton()
        } else {
            self.disableButton()
        }
    }
    
    func disableButton() {
        loginButton.backgroundColor = .gray
        loginButton.isEnabled = false
    }
    
    func enableButton() {
        loginButton.backgroundColor = .blue
        loginButton.isEnabled = true
    }
    
}

//MARK: - IBActions
private extension GCLoginViewController {
    //email
    @IBAction func emailBeginEditing(_ sender: Any) {
        if errorInLogin {
            resetErrorLogin(emailTextField)
        } else {
            emailTextField.setEditingColor()
        }
    }
    
    @IBAction func emailEditing(_ sender: Any) {
        validateButton()
    }
    
    @IBAction func emailEndEditing(_ sender: Any) {
        emailTextField.setDefaultColor()
    }
    
    //password
    @IBAction func passwordBeginEditing(_ sender: Any) {
        if errorInLogin {
            resetErrorLogin(passwordTextField)
        } else {
            passwordTextField.setEditingColor()
        }
    }
    
    @IBAction func passwordEditing(_ sender: Any) {
        validateButton()
    }
    
    @IBAction func passwordEndEditing(_ sender: Any) {
        passwordTextField.setDefaultColor()
    }
    
    @IBAction func resetPasswordButton(_ sender: Any) {
        gcLoginCoordinator.showGCResetPasswordViewController(presentController: self)
    }
    
    @IBAction func createAccountButton(_ sender: Any) {
        let controller = GCCreateAccountViewController()
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    @IBAction func showPasswordButton(_ sender: Any) {
        passwordTextField.isSecureTextEntry = showPassword
        setupPasswordButtonImage()
        showPassword.toggle()
    }
    
    @IBAction private func loginButton(_ sender: Any) {
        let isInternetConnected = ConnectivityManager.shared.isConnected
        
        if  isInternetConnected {
            showLoading()
            validateLogin()
        } else {
            gcAlert.showNoInternetCOnnection(controller: self)
        }
    }

    
}
