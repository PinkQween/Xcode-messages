//
//  RegisterViewController.swift
//  messages2
//
//  Created by Hanna Skairipa on 1/13/23.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
                
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
    
    private let UsernameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.backgroundColor = UIColor.lightGray.cgColor
        field.placeholder = "Username"
        
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
    
    private let RegisterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register"
        view.backgroundColor = .white
        
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        RegisterButton.addTarget(self, action: #selector(RegisterButtonTapped), for: .touchUpInside)
        
        EmailField.delegate = self
        PasswordField.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(UsernameField)
        scrollView.addSubview(EmailField)
        scrollView.addSubview(PasswordField)
        scrollView.addSubview(RegisterButton)
        
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfile))
        gesture.numberOfTouchesRequired = 1
        gesture.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(gesture)
    }
    
    @objc private func didTapChangeProfile() {
        presentPhotoActionSheet()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2, y: 25, width: size, height: size)
        imageView.layer.cornerRadius = imageView.width/2.0
        UsernameField.frame = CGRect(x: 30, y: imageView.bottom + 45, width: scrollView.width - 60, height: 52)
        EmailField.frame = CGRect(x: 30, y: UsernameField.bottom + 10, width: scrollView.width - 60, height: 52)
        PasswordField.frame = CGRect(x: 30, y: EmailField.bottom + 10, width: scrollView.width - 60, height: 52)
        RegisterButton.frame = CGRect(x: 30, y: PasswordField.bottom + 10, width: scrollView.width - 60, height: 52)
    }
    
    @objc private func RegisterButtonTapped() {
        EmailField.resignFirstResponder()
        UsernameField.resignFirstResponder()
        PasswordField.resignFirstResponder()
        
        guard let username = UsernameField.text, let email = EmailField.text, let password = PasswordField.text, !email.isEmpty, !username.isEmpty, !password.isEmpty, password.count >= 8 else {
            alertUserLoginError()
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard let result = authResult, error == nil else {
                print("Error creating user")
                return
            }
            
            let user = result.user
            print("Created user: \(user)")
        }
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

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == EmailField {
            PasswordField.becomeFirstResponder()
        } else if textField == PasswordField {
            RegisterButtonTapped()
        }
        
        return true
    }
}


extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture", message: "Please select photo or camera", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {[weak self] _ in self?.presentCamera()}))
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: {[weak self] _ in self?.presentPhotoPicker()}))
        
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(info)
        picker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.imageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
