
#if os(WASI)
import Sync
import TokamakCore
import OpenCombine

@dynamicMemberLookup
@propertyWrapper
public struct SyncedObject<Value : SyncableObject>: DynamicProperty {
    private class Storage {
        var value: Value

        init(value: Value) {
            self.value = value
        }
    }

    @ObservedObject
    private var fakeObservable: FakeObservableObject

    private let manager: AnyManager
    private let storage: Storage

    public var wrappedValue: Value {
        get {
            return storage.value
        }
    }

    public var projectedValue: SyncedObject<Value> {
        return self
    }

    private init(value: Value, manager: AnyManager) {
        self._fakeObservable = ObservedObject(wrappedValue: FakeObservableObject(manager: manager))
        self.storage = Storage(value: value)
        self.manager = manager
    }

    init(syncManager: SyncManager<Value>) throws {
        self.init(value: try syncManager.value(), manager: Manager(manager: syncManager))
    }

    func forceUpdate(value: Value) {
        self.storage.value = value
        fakeObservable.forceUpdate()
    }
}

extension SyncedObject {

    public var connection: Connection {
        return manager.connection
    }

}

extension SyncedObject {

    public subscript<Subject : SyncableObject>(dynamicMember keyPath: KeyPath<Value, Subject>) -> SyncedObject<Subject> {
        return SyncedObject<Subject>(value: storage.value[keyPath: keyPath], manager: manager)
    }

    public subscript<Subject : Codable>(dynamicMember keyPath: WritableKeyPath<Value, Subject>) -> Binding<Subject> {
        return Binding(get: { self.storage.value[keyPath: keyPath] }, set: { self.storage.value[keyPath: keyPath] = $0 })
    }

}

private final class FakeObservableObject: ObservableObject {
    private let manualUpdate = PassthroughSubject<Void, Never>()
    private let manager: AnyManager

    let objectWillChange = ObservableObjectPublisher()
    private var cancellables: Set<AnyCancellable> = []

    init(manager: AnyManager) {
        self.manager = manager
        let changeEvents = manager.eventHasChanged
        let connectionChange: AnyPublisher<Void, Never> = manager.connection.isConnectedPublisher.removeDuplicates().map { _ in () }.eraseToAnyPublisher()

        changeEvents
            .merge(with: connectionChange)
            .merge(with: manualUpdate)
            .sink { [unowned self] in objectWillChange.send() }
            .store(in: &cancellables)
    }

    func forceUpdate() {
        manualUpdate.send()
    }
}

private class AnyManager {
    var connection: Connection {
        fatalError()
    }

    var eventHasChanged: AnyPublisher<Void, Never> {
        fatalError()
    }
}

private final class Manager<Root : SyncableObject>: AnyManager {
    let manager: SyncManager<Root>

    init(manager: SyncManager<Root>) {
        self.manager = manager
    }

    override var eventHasChanged: AnyPublisher<Void, Never> {
        return manager.eventHasChanged
    }

    override var connection: Connection {
        return manager.connection
    }
}

extension Publisher {

    func merge<P>(with other: P) -> Merge<Self, P> where P : Publisher, Self.Failure == P.Failure, Self.Output == P.Output {
        return Merge(a: self, b: other)
    }

}

struct Merge<A: Publisher, B: Publisher>: Publisher where A.Output == B.Output, A.Failure == B.Failure {
    typealias Output = A.Output
    typealias Failure = B.Failure

    let a: A
    let b: B

    func merge<C>(with c: C) -> Merge3<A, B, C> where C : Publisher, Self.Failure == C.Failure, Self.Output == C.Output {
        return Merge3(a: a, b: b, c: c)
    }

    func receive<S>(subscriber: S) where S : Subscriber, B.Failure == S.Failure, A.Output == S.Input {
        a.receive(subscriber: subscriber)
        b.receive(subscriber: subscriber)
    }
}

struct Merge3<A: Publisher, B: Publisher, C: Publisher>: Publisher where A.Output == B.Output, A.Output == C.Output, A.Failure == B.Failure, A.Failure == C.Failure {
    typealias Output = A.Output
    typealias Failure = B.Failure

    let a: A
    let b: B
    let c: C

    func receive<S>(subscriber: S) where S : Subscriber, B.Failure == S.Failure, A.Output == S.Input {
        a.receive(subscriber: subscriber)
        b.receive(subscriber: subscriber)
        c.receive(subscriber: subscriber)
    }
}
#else
@_exported import Sync
#endif
