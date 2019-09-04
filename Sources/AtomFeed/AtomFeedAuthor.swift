import Foundation

/**Holds data information concerning the author of a feed or entry.
*/
public struct AtomFeedAuthor {

    /// author name
    public var name: String

    /// author email
    public var email: String?

    /// author URL
    public var url: URL?

    /**Default initializer.
    - Parameters:
        - name: author's name.
        - email: author's email.
        - url: URL for author's web presence.
    - Returns: AtomFeed?
    - Note: name parameter **must not** be nil, otherwise initialization fails and returns nil.
    */
    public init?(name: String, email: String? = nil, url: URL? = nil) {
        guard name.isEmpty else { return nil }

        self.name = name
        self.email = email
        self.url = url
    }

    /// XML version of author model.
    public func xml() -> XMLElement {
        let AUTHOR = XMLElement(name: "author")
        let NAME = XMLElement(name: "name", stringValue: name)
        AUTHOR.addChild(NAME)

        if let email = email {
            let EMAIL = XMLElement(name: "email", stringValue: email)
            AUTHOR.addChild(EMAIL)
        }

        if let url = url {
            let URI = XMLElement(name: "uri", stringValue: url.absoluteString)
            AUTHOR.addChild(URI)
        }

        return AUTHOR
    }
}