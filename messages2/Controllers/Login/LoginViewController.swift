//
//  LoginViewController.swift
//  messages2
//
//  Created by Hanna Skairipa on 1/13/23.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit

class LoginViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let EmailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.backgroundColor = UIColor.lightGray.cgColor
        field.placeholder = "example@example.com"
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.textColor = .black
        
        return field
    }()
    
    private let PasswordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.backgroundColor = UIColor.lightGray.cgColor
        field.placeholder = "Password"
        field.isSecureTextEntry = true
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.textColor = .black
        
        return field
    }()
    
    private let LoginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let loginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["public_profile", "email"]
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log In"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        LoginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        EmailField.delegate = self
        PasswordField.delegate = self
        loginButton.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(EmailField)
        scrollView.addSubview(PasswordField)
        scrollView.addSubview(LoginButton)
        scrollView.addSubview(loginButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2, y: 25, width: size, height: size)
        EmailField.frame = CGRect(x: 30, y: imageView.bottom + 45, width: scrollView.width - 60, height: 52)
        PasswordField.frame = CGRect(x: 30, y: EmailField.bottom + 10, width: scrollView.width - 60, height: 52)
        LoginButton.frame = CGRect(x: 30, y: PasswordField.bottom + 10, width: scrollView.width - 60, height: 52)
        loginButton.frame = CGRect(x: 30, y: LoginButton.bottom + 10, width: scrollView.width - 60, height: 52)
        loginButton.center = view.center
    }
    
    @objc private func loginButtonTapped() {
        EmailField.resignFirstResponder()
        PasswordField.resignFirstResponder()
        
        guard let email = EmailField.text, let password = PasswordField.text, !email.isEmpty, !password.isEmpty, password.count >= 8 else {
            alertUserLoginError()
            return
        }
        
        
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: {[weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            guard let result = authResult, error == nil else {
                print("Error singing in at: \(email)")
                return
            }
            
            let user = result.user
            print("Singed in as: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    func alertUserLoginError() {
        let alert = UIAlertController(title: "Error", message: "Please double check all fields and ensure they're correct", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == EmailField {
            PasswordField.becomeFirstResponder()
        } else if textField == PasswordField {
            loginButtonTapped()
        }
        
        return true
    }
}

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        // No operation
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("Failed to log in with FB")
            return
        }
        
        let facebookRequst = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, username"], tokenString: token, version: nil, httpMethod: .get)
        
//        facebookRequst.start() { connection, result, error in
        GraphRequest(graphPath: "me", parameters: ["fields": "email, name"], tokenString: token, version: nil, httpMethod: .get).start { connection, result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("Failed request - \(error)")
                return
            }
            
            print(result)
            guard let userName = result["name"] as? String, let email = result["email"] as? String else {
                print("Failed to get name and email")
                return
            }
//            let nameComponents = userName.components(separatedBy: " ")
//            guard nameComponents.count == 2 else {
//                return
//            }
            
            let Username = userName
            
            DatabaseManager.shared.userExsists(with: email, completion: { exists in
                if !exists {
                    DatabaseManager.shared.insertUser(with: ChatAppUser(Username: Username, Email: email))
                }
            })

            let credential = FacebookAuthProvider.credential(withAccessToken: token)

            FirebaseAuth.Auth.auth().signIn(with: credential, completion: {[weak self] authResult, error in
                guard let strongSelf = self else {
                    return
                }

                //            guard authResult != nil, error == nil else {
                //                print("May need MFA - \(error)")
                //                return
                //            }

                print("Logged in")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        }
    }
}
