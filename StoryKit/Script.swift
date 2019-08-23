//
//  Script.swift
//  StoryKit
//
//  Created by John Clayton on 8/25/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit

protocol Scriptable {
	func matches(string: String) -> Bool
}

struct InputMatcher<Input> {
	enum Error: Swift.Error {
		case couldNotTransformValueToType(value: Any, type: Any.Type)
	}

	typealias Transformer = (String) -> Input

	let pattern: String
	let regularExpression: NSRegularExpression

	init!(pattern: String, options: NSRegularExpression.Options = [], transform: @escaping Transformer) {
		self.pattern = pattern
		self.regularExpression = try! NSRegularExpression(pattern: pattern, options: options)
		self.transform = transform
	}

	func matches(string: String) -> Bool {
		return regularExpression.rangeOfFirstMatch(in: string, options: [.anchored], range: NSMakeRange(0, (string as NSString).length)).location != NSNotFound
	}

	func value(from: String) throws -> Input {
		let range = from.startIndex..<from.endIndex
		if let _ = regularExpression.firstMatch(in: from, options: [.anchored], range: NSRange(range, in: from)) {
			return transform(from)
		}
		throw Error.couldNotTransformValueToType(value: from, type: Input.self)
	}

	let transform: Transformer
}

protocol InputCapturing {
	typealias AnyTransform = (String) -> Any
	var label: String { get }
	var pattern: String { get }
	var transform: AnyTransform { get }
	var inputString: String! { get }
}

protocol MutableInputCapturing: InputCapturing {
	var inputString: String! { get set }
}

class InputCaptureScene<Input> : SceneProtocol {
	enum Error: Swift.Error, CustomStringConvertible {
		case missingInput
		var description: String {
			switch self {
			case .missingInput:
				return "Tried building a scene with missing input \(String(describing: Input.self))"
			}
		}
	}

	let source: SceneDescriptor? = nil
	private(set) var destination: SceneDescriptor?
	private(set) var transition: TransitionProtocol
	let condition: Condition? = nil
	var junctionWith: SceneProtocol?
	var name: String {
		return "\(matcher.pattern)"
	}

	private(set) var matcher: InputMatcher<Input>
	var inputString: String!

	init(factory: @escaping (Input) -> SceneDescriptor, capture: String, label: String? = nil, transform: @escaping (String) -> Input, transition: TransitionProtocol) {
		self.factory = factory
		self.matcher = InputMatcher(pattern: capture, transform: transform)
		_label = label
		self.transition = transition
	}

	func destinationSceneController() throws -> UIViewController? {
		guard let inputString = inputString else {
			throw Error.missingInput
		}
		let input = try matcher.value(from: inputString)
		if let viewController = _viewController  {
			return viewController
		}
		let descriptor: SceneDescriptor = factory(input)
		let controller = try descriptor.sceneController()
		_viewController = controller
		destination = descriptor
		return controller
	}

	private var factory: (Input) -> SceneDescriptor
	private var _label: String?
	private var _viewController: UIViewController?
}

extension InputCaptureScene: Scriptable {
	func matches(string: String) -> Bool {
		return matcher.matches(string: string)
	}
}

extension InputCaptureScene: PathRepresentable {
	var segmentRepresentation: String {
		if let _ = inputString {
			return inputString
		}
		return "\(label)=(\(pattern))"
	}
}

extension InputCaptureScene: InputCapturing {
	var label: String {
		return _label ?? destination?.name ?? "???"
	}
	var pattern: String {
		return matcher.pattern
	}
	var transform: (String) -> Any {
		return matcher.transform as (String) -> Any
	}
}
extension InputCaptureScene: MutableInputCapturing {}

extension InputCaptureScene: CustomStringConvertible {
	var description: String {
		let address = Int(bitPattern: ObjectIdentifier(self))
		return String(format: "<%@ %0llx> name = %@, transition = %@, label = %@", String(describing: InputCaptureScene.self), address, name, String(describing: transition), label)
	}
	var shorthand: String {
		return "\(transition.operator)(\(label)=\(pattern))"
	}
}

class Prop: SceneProtocol {
	let source: SceneDescriptor? = nil
	let destination: SceneDescriptor? = nil
	let transition: TransitionProtocol = SystemTransition.none
	let condition: Condition? = nil
	var junctionWith: SceneProtocol? {
		get { return nil }
		set {}
	}

	var name: String
	init(name: String) {
		self.name = name
	}

	func destinationSceneController() throws -> UIViewController? { return nil }
}

public final class Script: Storyish {
	public var name: String?
	private(set) public var scenes: [AnyScene]
	private(set) public var base: Storyish? = nil
	private(set) public var stage: Stage? = nil
	private(set) public var identifier: UUID = UUID()

	init(scenes: [AnyScene] = [], stage: Stage? = nil) {
		self.scenes = scenes
		self.stage = stage
	}

	func asStory() -> Story {
		//???: Does it make sense to validate the scenes have the requisite input here?
		return Story(scenes, stage: stage)
	}
}

extension Script: CustomStringConvertible {
	public var description: String {
		let address = Int(bitPattern: ObjectIdentifier(self))
		return String(format: "<%@ %0llx> name = %@, scenes = %@", String(describing: Script.self), address, String(describing: name), proofedScenes())
	}
}

extension Script: Composable {
	@discardableResult public func append(_ scene: AnyScene) -> Script {
		let previousScene = scenes.last
		scenes.append(scene)
		if previousScene != nil && previousScene!.transition.isJunction {
			previousScene!.junctionWith = scene
		}
		return self
	}
}

extension Script: Narratable {
	public func segue(toScene scene: SceneDescriptor?, transition: TransitionProtocol, source: SceneDescriptor? = nil, unlessConditionMet condition: Condition? = nil) -> Script {
		return self.append(Scene(descriptor: scene, transition: transition, source: source, condition: condition))
	}
}

public extension Narratable where Self == Script {
	@discardableResult func plot<S: SceneDescriptor, T: TransitionProtocol>(futureScene scene: @escaping (String) -> S, capture pattern: String, label: String? = nil, transition: T, unlessConditionMet condition: Condition? = nil) -> Script {
		return self.plot(futureScene: scene, capture: pattern, label: label, transform: {$0}, transition: transition)
	}

	@discardableResult func plot<S: SceneDescriptor, T: TransitionProtocol, Input>(futureScene scene: @escaping (Input) -> S, capture pattern: String, label: String? = nil,  transform: @escaping (String) -> Input, transition: T, unlessConditionMet condition: Condition? = nil) -> Script {
		let scene = InputCaptureScene(factory: scene, capture: pattern, label: label, transform: transform, transition: transition)
		return self.append(scene)
	}
}

public extension Narratable where Self == Script {
	@discardableResult func root<S: SceneDescriptor>(_ scene: @escaping (String) -> S, capture pattern: String, label: String? = nil, unlessConditionMet condition: Condition? = nil) -> Self {
		return plot(futureScene: scene, capture: pattern, label: label, transition: SystemTransition.root)
	}

	@discardableResult func root<S: SceneDescriptor, Input>(_ scene: @escaping (Input) -> S, capture pattern: String, label: String? = nil, transform: @escaping (String) -> Input, unlessConditionMet condition: Condition? = nil) -> Self {
		return plot(futureScene: scene, capture: pattern, label: label, transform: transform, transition: SystemTransition.root)
	}

	@discardableResult func select<S: SceneDescriptor>(_ scene: @escaping (String) -> S, capture pattern: String, label: String? = nil, unlessConditionMet condition: Condition? = nil) -> Self {
		return plot(futureScene: scene, capture: pattern, label: label, transition: SystemTransition.select)
	}

	@discardableResult func select<S: SceneDescriptor, Input>(_ scene: @escaping (Input) -> S, capture pattern: String, label: String? = nil, transform: @escaping (String) -> Input, unlessConditionMet condition: Condition? = nil) -> Self {
		return plot(futureScene: scene, capture: pattern, label: label, transform: transform, transition: SystemTransition.select)
	}

	@discardableResult func set<S: SceneDescriptor>(_ scene: @escaping (String) -> S, capture pattern: String, label: String? = nil, unlessConditionMet condition: Condition? = nil) -> Self {
		return plot(futureScene: scene, capture: pattern, label: label, transition: SystemTransition.set)
	}

	@discardableResult func set<S: SceneDescriptor, Input>(_ scene: @escaping (Input) -> S, capture pattern: String, label: String? = nil, transform: @escaping (String) -> Input, unlessConditionMet condition: Condition? = nil) -> Self {
		return plot(futureScene: scene, capture: pattern, label: label, transform: transform, transition: SystemTransition.set)
	}

	@discardableResult func push<S: SceneDescriptor>(_ scene: @escaping (String) -> S, capture pattern: String, label: String? = nil, unlessConditionMet condition: Condition? = nil) -> Self {
		return plot(futureScene: scene, capture: pattern, label: label, transition: SystemTransition.push)
	}

	@discardableResult func push<S: SceneDescriptor, Input>(_ scene: @escaping (Input) -> S, capture pattern: String, label: String? = nil, transform: @escaping (String) -> Input, unlessConditionMet condition: Condition? = nil) -> Self {
		return plot(futureScene: scene, capture: pattern, label: label, transform: transform, transition: SystemTransition.push)
	}

	@discardableResult func pop<S: SceneDescriptor>(_ scene: @escaping (String) -> S, capture pattern: String, label: String? = nil, unlessConditionMet condition: Condition? = nil) -> Self {
		return plot(futureScene: scene, capture: pattern, label: label, transition: SystemTransition.pop)
	}

	@discardableResult func pop<S: SceneDescriptor, Input>(_ scene: @escaping (Input) -> S, capture pattern: String, label: String? = nil, transform: @escaping (String) -> Input, unlessConditionMet condition: Condition? = nil) -> Self {
		return plot(futureScene: scene, capture: pattern, label: label, transform: transform, transition: SystemTransition.pop)
	}

	@discardableResult func present<S: SceneDescriptor>(_ scene: @escaping (String) -> S, capture pattern: String, label: String? = nil, unlessConditionMet condition: Condition? = nil) -> Self {
		return plot(futureScene: scene, capture: pattern, label: label, transition: SystemTransition.present)
	}

	@discardableResult func present<S: SceneDescriptor, Input>(_ scene: @escaping (Input) -> S, capture pattern: String, label: String? = nil, transform: @escaping (String) -> Input, unlessConditionMet condition: Condition? = nil) -> Self {
		return plot(futureScene: scene, capture: pattern, label: label, transform: transform, transition: SystemTransition.present)
	}

	@discardableResult func dismiss<S: SceneDescriptor>(_ scene: @escaping (String) -> S, capture pattern: String, label: String? = nil, unlessConditionMet condition: Condition? = nil) -> Self {
		return plot(futureScene: scene, capture: pattern, label: label, transition: SystemTransition.dismiss)
	}

	@discardableResult func dismiss<S: SceneDescriptor, Input>(_ scene: @escaping (Input) -> S, capture pattern: String, label: String? = nil, transform: @escaping (String) -> Input, unlessConditionMet condition: Condition? = nil) -> Self {
		return plot(futureScene: scene, capture: pattern, label: label, transform: transform, transition: SystemTransition.dismiss)
	}

	@discardableResult func unwind<S: SceneDescriptor>(_ scene: @escaping (String) -> S, capture pattern: String, label: String? = nil, unlessConditionMet condition: Condition? = nil) -> Self {
		return plot(futureScene: scene, capture: pattern, label: label, transition: SystemTransition.unwind)
	}

	@discardableResult func unwind<S: SceneDescriptor, Input>(_ scene: @escaping (Input) -> S, capture pattern: String, label: String? = nil, transform: @escaping (String) -> Input, unlessConditionMet condition: Condition? = nil) -> Self {
		return plot(futureScene: scene, capture: pattern, label: label, transform: transform, transition: SystemTransition.unwind)
	}

	@discardableResult func prop(_ name: String) -> Self {
		return self.append(Prop(name: name))
	}
}

extension Script: Performable {
	public func insert() {
		self.asStory().insert()
	}
	public func perform(animated: Bool = true, completion: Ovation? = nil ) {
		self.asStory().perform(animated: animated, completion: completion)
	}
}


//MARK: Value binding & URL convertibility


 // We need a composit of input capturing and scene to handle capture scenes while enforcing the mutability rules of input capturing
protocol InputCapturingScene: InputCapturing, SceneProtocol {
	func mutableCopy() -> MutableInputCapturingScene
}
protocol MutableInputCapturingScene: MutableInputCapturing, SceneProtocol {}

extension InputCaptureScene: InputCapturingScene {
	func mutableCopy() -> MutableInputCapturingScene {
		return InputCaptureScene(factory: factory, capture: matcher.pattern, transform: matcher.transform, transition: transition)
	}
}
extension InputCaptureScene: MutableInputCapturingScene {}

public protocol URLConvertibility {
	var pathRepresentation: String { get }
	var captureSegments: [(label: String, pattern: String)] { get }
	func bind(inputs: [String]) throws -> Script
	func bind(pathSegments: [String]) throws -> Script
}

extension Script: URLConvertibility {
	enum Error: Swift.Error {
		case inputCaptureCountMismatch(expected: Int, got: Int)
		case inputCaptureIndexOverflow(got: Int, count: Int)
		case inputScenePatternMismatch(segment: String, pattern: String)
		case segmentSceneCountMismatch(expected: Int, got: Int)
		case segmentIndexOverflow(got: Int, count: Int)
		case segmentSceneMissingInput(scene: SceneProtocol)
		case segmentScenePatternMismatch(segment: String, pattern: String)
	}

	var pathScenes: [AnyScene] {
		var pathScenes = [AnyScene]()
		for scene in scenes {
			guard !scene.isJunction else { continue }
			pathScenes.append(scene)
		}
		return pathScenes
	}

	public var pathRepresentation: String {
		var pathComponents = [String]()
		for scene in pathScenes {
			if scene.isRoot  {
				pathComponents.append("")
			} else {
				pathComponents.append(scene.segmentRepresentation)
			}
		}
		return pathComponents.joined(separator: "/")
	}
	
	private var captureScenes: [InputCapturingScene] {
		return pathScenes.compactMap { $0.value as? InputCapturingScene }
	}

	public var captureSegments: [(label: String, pattern: String)] {
		return captureScenes.map { ($0.label, $0.pattern) }
	}

	public func bind(inputs: [String]) throws -> Script {
		let captureScenes = self.captureScenes
		guard inputs.count == captureScenes.count else {
			throw Error.inputCaptureCountMismatch(expected: captureScenes.count, got: inputs.count)
		}
		let script = Script(stage: stage)
		var captureIndex = 0
		for scene in scenes {
			if let captureScene = scene.value as? InputCapturingScene {
				guard captureIndex < captureScenes.count else {
					throw Error.inputCaptureIndexOverflow(got: captureIndex, count: captureScenes.count)
				}
				let input = inputs[captureIndex]
				captureIndex += 1
				guard captureScene.matches(string: input) else {
					throw Error.inputScenePatternMismatch(segment: input, pattern: captureScene.pattern)
				}
				var mutableScene = captureScene.mutableCopy()
				mutableScene.inputString = input
				script.append(mutableScene)
			} else {
				script.append(scene)
			}
		}
		return script
	}

	public func bind(pathSegments: [String]) throws -> Script {
		let pathScenes = self.pathScenes
		guard pathSegments.count == pathScenes.count else {
			throw Error.inputCaptureCountMismatch(expected: pathScenes.count, got: pathSegments.count)
		}
		let script = Script(stage: stage)
		var segmentIndex = 0
		for scene in scenes {
			var segment: String? = nil
			if pathScenes.contains(scene) {
				guard segmentIndex < pathScenes.count else {
					throw Error.segmentIndexOverflow(got: segmentIndex, count: pathScenes.count)
				}
				segment = pathSegments[segmentIndex]
				segmentIndex += 1
			}

			if let captureScene = scene.value as? InputCapturingScene {
				guard let segment = segment else {
					throw Error.segmentSceneMissingInput(scene: captureScene)
				}
				guard captureScene.matches(string: segment) else {
					throw Error.segmentScenePatternMismatch(segment: segment, pattern: captureScene.pattern)
				}
				var mutableScene = captureScene.mutableCopy()
				mutableScene.inputString = segment
				script.append(mutableScene)
			} else {
				script.append(scene)
			}
		}
		return script
	}
}

