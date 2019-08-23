//
//  StoryboardSceneDescriptor.template.swift
//  StoryKitTool
//
//  Created by John Clayton on 1/19/19.
//  Copyright © 2019 Impossible Flight, LLC. All rights reserved.
//


struct Keys {
	static var main = "main"
	static var `extension` = "extension"
	struct Storyboard {
		static var name = "name"
		static var cases = "cases"
	}
	struct Controller {
		static var storyboardIdentifier = "storyboardIdentifier"
		static var inputSignature = "inputSignature"
		static var isContainerScoped = "isContainerScoped"
		static var customClass = "customClass"
		static var inputLabel = "inputLabel"
		static var inputType = "inputType"
	}
}

extension Storyboard {
	var templateContext: [String:Any] {
		let cases = self.controllers.reduce([[String:Any]]()) { (cases, controller) in
			if let context = controller.templateContext {
				return cases + [context]
			}
			return cases
		}
		return [Keys.Storyboard.name : self.name, Keys.Storyboard.cases : cases]
	}
}

extension Controller {
	var templateContext: [String:Any]? {
		if let storyboardIdentifier = storyboardIdentifier {
			var context = [String:Any]()
			context[Keys.Controller.storyboardIdentifier] = storyboardIdentifier
			context[Keys.Controller.inputSignature] = inputSignature ?? ""
			context[Keys.Controller.isContainerScoped] = isContainerScoped
			context[Keys.Controller.customClass] = customClass
			context[Keys.Controller.inputLabel] = inputLabel ?? ""
			return context
		}
		return nil
	}
}

let __template__ = """
// This section is automatically generated. DO NOT EDIT.
{{ main }}

{{ extension }}
"""

let __main__ = """
// storykit:inline:{{ name }}.StoryboardSceneDescriptor
import UIKit
import StoryKit

enum {{ name }} { {% for case in cases %}
	case {{ case.storyboardIdentifier }}{{ case.inputSignature }}{% endfor %}
}

extension {{ name }}: StoryboardSceneDescriptor {
	func sceneController() throws -> UIViewController {
		switch self { {% for case in cases %}{% if case.inputSignature %}
		case let .{{ case.storyboardIdentifier }}({{ case.inputLabel }}):
			return try sceneControllerFromStoryboard() { (controller: {{case.customClass|default:"UIViewController"}}) in
				didLoad(sceneController: controller)
			}{% else %}
		case .{{ case.storyboardIdentifier }}:
			return try sceneControllerFromStoryboard({% if case.isContainerScoped %}inScope: .container {% endif %}) { (controller: {{case.customClass|default:"UIViewController"}}) in
				didLoad(sceneController: controller)
			}{% endif %}{% endfor %}
		}
	}

	static var restorationIdentifiers: [{{ name }}] {
		return [{% for case in cases where not case.inputSignature %}
			{% if not forloop.first %},{% endif %}.{{case.storyboardIdentifier}}{% endfor %}
		]
	}
}
// storykit:end
"""

let __extension__ = """
// This extension may be manually edited
extension {{ name }}: SceneControllerInitializing {
	// Perform custom scene controller initialization here.
	func didLoad<V: UIViewController>(sceneController: V) {
		/*
		switch self { {% for case in cases %}{% if case.inputSignature %}
		case let .{{ case.storyboardIdentifier }}({{ case.inputLabel }}):
			// Do any additional setup after loading from storyboard
			// Like binding controller to the incoming values...
			// controller.{{ case.inputLabel }} = {{ case.inputLabel }}{% else %}
		case .{{ case.storyboardIdentifier }}:
			// Do any additional setup after loading from storyboard{% endif %}{% endfor %}
		}
		*/
	}
}
"""
