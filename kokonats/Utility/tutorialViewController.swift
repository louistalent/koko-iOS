//  kokonats
//
//  Created by Pedro Diaz on 2022/04/25.
//
//

import Foundation
import UIKit

class tutorialViewController: UIViewController  {

    let tutorial1View = UIView()
    let tutorial2View = UIView()
    let tutorial3View = UIView()
    
    let tutorialStackView = UIStackView()
    
    let prevButton = UIButton()
    let nextButton = UIButton()
    var tutorial3taptext = UILabel()
    
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tutorialStackView.axis = .horizontal
        tutorialStackView.isUserInteractionEnabled = true
        view.backgroundColor = .white.withAlphaComponent(0)
        view.cornerRadius = 12
        
        view.addSubview(tutorialStackView)
        
        tutorialStackView.addArrangedSubview(tutorial1View)
        tutorialStackView.addArrangedSubview(tutorial2View)
        tutorialStackView.addArrangedSubview(tutorial3View)
        
        tutorialStackView.arrangedSubviews[1].isHidden = true
        tutorialStackView.arrangedSubviews[2].isHidden = true
        tutorialStackView.arrangedSubviews[0].isHidden = false
     
        configureTutorial1()
        configureTutorial2()
        configureTutorial3()
        	
        tutorial3taptext.isHidden = true
        
    }
    
    private func configureTutorial1() {
        
        tutorial1View.translatesAutoresizingMaskIntoConstraints = false
        tutorial1View.backgroundColor = .white
        tutorial1View.isUserInteractionEnabled = true
        
        modalPresentationStyle = .fullScreen
        
       
        let tutor1_back = UIImageView()
        tutorial1View.addSubview(tutor1_back)
        tutor1_back.activeConstraints( to: view ,directions: [ .centerY, .centerX])
        tutor1_back.image = UIImage(named: "tutorial1_back.png")
        
        let bigVector = UIImageView()
        tutorial1View.addSubview(bigVector)
        bigVector.activeConstraints( to:view , directions: [ .centerX, .top(.top, 144)])
        bigVector.image = UIImage(named: "tutorial1_big_vector.png")
        
        let itemback1 = UIImageView()
        tutorial1View.addSubview(itemback1)
        itemback1.activeConstraints(to:view , directions: [ .centerX, .top(.top, 245)])
        itemback1.image = UIImage(named: "tutorial1_itemback.png")

        let smallVector = UIImageView()
        tutorial1View.addSubview(smallVector)
        smallVector.activeConstraints( to:view ,directions: [ .leading(.leading, 119), .top(.top, 255)])
        smallVector.image = UIImage(named: "tutorial1_small_vector.png")

        let tutor1_200 = UILabel()
        tutorial1View.addSubview(tutor1_200)
        tutor1_200.font = UIFont.getKokoFont(type: .bold, size: 28)
        tutor1_200.textColor = .white
        tutor1_200.text = "\(200)"
        tutor1_200.textAlignment = .left
        tutor1_200.numberOfLines = 1
        tutor1_200.activeConstraints(to: view,directions: [.leading(.leading,144),.top(.top, 248)])

        let coolItem = UIImageView()
        tutorial1View.addSubview(coolItem)
        coolItem.activeConstraints(to: view, directions: [ .leading(.leading, 240), .top(.top, 254)])
        coolItem.image = UIImage(named: "tutorial1_coolicon.png")

        let tutorialcontent = UILabel.formatedLabel(size: 20, text: "tutorial1_content".localized, type: .bold)
        tutorialcontent.textColor = .black
        tutorialcontent.textAlignment = .center
        tutorialcontent.lineBreakMode = .byWordWrapping
        tutorialcontent.numberOfLines = 4
        tutorial1View.addSubview(tutorialcontent)
        tutorialcontent.activeConstraints( to: view, directions: [.centerX,.top(.top, 327)])
        
        let bottomLabel = UILabel.formatedLabel(size: 16, text: "1/3", type: .bold)
        bottomLabel.textColor = .black
        bottomLabel.textAlignment = .center
        tutorial1View.addSubview(bottomLabel)
        bottomLabel.activeConstraints( to:view,directions: [.centerX,.top(.top, 625)])

        view.addSubview(nextButton)
        nextButton.activeConstraints(to:view, directions: [.trailing(.trailing, -56), .top(.top, 625)])
        nextButton.setImage(UIImage(named: "nextbutton.png"), for: .normal)
        nextButton.addTarget(self, action: #selector(goNext), for: .touchUpInside)
    }

        private func configureTutorial2() {
        
        tutorial2View.translatesAutoresizingMaskIntoConstraints = false
        tutorial2View.backgroundColor = .white
        tutorial2View.isUserInteractionEnabled = true
                
        view.backgroundColor = .white.withAlphaComponent(0)
        view.cornerRadius = 12
        
        let tutor2_back = UIImageView()
        tutorial2View.addSubview(tutor2_back)
        tutor2_back.activeConstraints( to: view ,directions: [ .centerX, .centerY])
        tutor2_back.image = UIImage(named: "tutorial3_back.png")
      
        let dollar = UIImageView()
        tutorial2View.addSubview(dollar)
        dollar.activeConstraints(to: view, directions: [ .centerX, .top(.top, 144)])
        dollar.image = UIImage(named: "tutorial2_dollar.png")
        
        let tutor2_itemback = UIImageView()
        tutorial2View.addSubview(tutor2_itemback)
        tutor2_itemback.activeConstraints(to: view, directions: [ .centerX, .top(.top, 245)])
        tutor2_itemback.image = UIImage(named: "tutorial2_itemback.png")

        let smallellipse = UIImageView()
        tutorial2View.addSubview(smallellipse)
        smallellipse.activeConstraints(to: view, directions: [ .leading(.leading, 95), .top(.top, 265)])
        smallellipse.image = UIImage(named: "tutorial2_ellipse.png")

        let smallItemText = UIImageView()
        tutorial2View.addSubview(smallItemText)
        smallItemText.activeConstraints(to: view, directions: [ .leading(.leading, 117), .top(.top, 265)])
        smallItemText.image = UIImage(named: "tutorial2_small_text.png")

        let gold_1000 = UIImageView()
        tutorial2View.addSubview(gold_1000)
        gold_1000.activeConstraints(to: view, directions: [ .leading(.leading, 200), .top(.top, 260)])
        gold_1000.image = UIImage(named: "tutorial2_1000.png")

        let tutorialcontent2 = UILabel.formatedLabel(size: 20, text: "tutorial2_content".localized, type: .bold)
        tutorialcontent2.textColor = .black
        tutorialcontent2.textAlignment = .center
        tutorialcontent2.numberOfLines = 4
        tutorialcontent2.lineBreakMode = .byWordWrapping
        tutorial2View.addSubview( tutorialcontent2 )
        tutorialcontent2.activeConstraints( to: view ,directions: [ .centerX , .top( .top, 327 )])
            
        let bottomLabel2 = UILabel.formatedLabel(size: 16, text: "2/3", type: .bold)
        bottomLabel2.textColor = .black
        bottomLabel2.textAlignment = .center
        bottomLabel2.numberOfLines = 1
        tutorial2View.addSubview(bottomLabel2)
        bottomLabel2.activeConstraints(to:view,directions: [.centerX,.top(.top, 625)])
            
        /*let prevButton2 = UIButton()
        tutorial2View.addSubview(prevButton2)
        prevButton2.activeConstraints(to:view, directions: [.leading(.leading, 56), .top(.top, 625)])
        prevButton2.setImage(UIImage(named: "prevbutton.png"), for: .normal)
        prevButton2.addTarget(self, action: #selector(goPrev), for: .touchUpInside)

        let nextButton2 = UIButton()
        tutorial2View.addSubview(nextButton2)
        nextButton2.activeConstraints(to:view, directions: [.trailing(.trailing, -56), .top(.top, 625)])
        nextButton2.setImage(UIImage(named: "nextbutton.png"), for: .normal)
        nextButton2.addTarget(self, action: #selector(goNext), for: .touchUpInside)*/
        }
    

        private func configureTutorial3() {
        
        tutorial3View.translatesAutoresizingMaskIntoConstraints = false
        tutorial3View.backgroundColor = .white
        tutorial3View.isUserInteractionEnabled = true
        
        
        view.backgroundColor = .white.withAlphaComponent(0)
        view.cornerRadius = 12
        
        let tutor3_back = UIImageView()
        tutorial3View.addSubview(tutor3_back)
        tutor3_back.activeConstraints( to: view ,directions: [ .centerX, .centerY])
        tutor3_back.image = UIImage(named: "tutorial2_back.png")
        
        let tutor3_symbol = UIImageView()
        tutorial3View.addSubview(tutor3_symbol)
        tutor3_symbol.activeConstraints(to: view, directions: [ .centerX, .top(.top, 144)])
        tutor3_symbol.image = UIImage(named: "tutorial3_symbol.png")
        
        var tutorial3content = UILabel()
        tutorial3content = UILabel.formatedLabel(size: 20, text: "tutorial3_content".localized, type: .bold)
        tutorial3content.textColor = .black
        tutorial3content.textAlignment = .center
        tutorial3content.numberOfLines = 2
        tutorial3View.addSubview(tutorial3content)
        tutorial3content.activeConstraints(to:view,directions: [.centerX,.top(.top, 275)])
            
        tutorial3taptext = UILabel.formatedLabel(size: 20, text: "tutorial3_connect".localized, type: .bold)
        view.addSubview(tutorial3taptext)
        tutorial3taptext.textColor = .blue
        tutorial3taptext.textAlignment = .center
        tutorial3taptext.numberOfLines = 1
        tutorial3taptext.activeConstraints(to:view,directions: [.centerX,.top(.top, 364)])
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapText))
        tutorial3taptext.isUserInteractionEnabled = true
        tutorial3taptext.addGestureRecognizer(tap)
            
            
        var bottomLabel3 = UILabel()
        bottomLabel3 = UILabel.formatedLabel(size: 16, text: "3/3", type: .bold)
        bottomLabel3.textColor = .black
        bottomLabel3.textAlignment = .center
        bottomLabel3.numberOfLines = 1
        tutorial3View.addSubview(bottomLabel3)
        bottomLabel3.activeConstraints(to:view,directions: [.centerX,.top(.top, 625)])
            
    
        view.addSubview(prevButton)
        prevButton.activeConstraints(to:view, directions: [.leading(.leading, 56), .top(.top, 625)])
        prevButton.setImage(UIImage(named: "prevbutton"), for: .normal)
        prevButton.addTarget(self, action: #selector( self.goPrev), for: .touchUpInside)
        prevButton.isHidden = true
        }
    
        @objc func goPrev() {
            switch currentIndex {
            case 0:
                nextButton.isHidden = false
                prevButton.isHidden = true
            case 1:
                nextButton.isHidden = false
                prevButton.isHidden = true
                tutorialStackView.arrangedSubviews[1].isHidden = true
                tutorialStackView.arrangedSubviews[2].isHidden = true
                tutorialStackView.arrangedSubviews[0].isHidden = false
                tutorial3taptext.isHidden = true
                currentIndex = 0
            case 2:
                nextButton.isHidden = false
                prevButton.isHidden = false
                tutorialStackView.arrangedSubviews[0].isHidden = true
                tutorialStackView.arrangedSubviews[2].isHidden = true
                tutorialStackView.arrangedSubviews[1].isHidden = false
                tutorial3taptext.isHidden = true
                currentIndex = 1
            default:
                currentIndex = 0
            }
        }

        @objc func goNext() {
            switch currentIndex {
            case 0:
                nextButton.isHidden = false
                prevButton.isHidden = false
                tutorialStackView.arrangedSubviews[2].isHidden = true
                tutorialStackView.arrangedSubviews[0].isHidden = true
                tutorialStackView.arrangedSubviews[1].isHidden = false
                tutorial3taptext.isHidden = true
                currentIndex = 1
            case 1:
                nextButton.isHidden = true
                prevButton.isHidden = false
                tutorialStackView.arrangedSubviews[0].isHidden = true
                tutorialStackView.arrangedSubviews[1].isHidden = true
                tutorialStackView.arrangedSubviews[2].isHidden = false
                tutorial3taptext.isHidden = false
                currentIndex = 2
            case 2:
                nextButton.isHidden = true
                prevButton.isHidden = false
            default:
                currentIndex = 0
            }
        }
    
        @objc func tapText(){
            let defaults = UserDefaults.standard
            //Set
            defaults.set("isViewed", forKey: "viewOption")
            dismiss(animated: true)
        }

}




