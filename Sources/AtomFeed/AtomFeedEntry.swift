import Foundation

public class AtomFeedEntry: Equatable {

    /// entry identifier
    public let ID: String

    /// entry title
    public var title: String

    /// entry author
    public var author: AtomFeedAuthor

    /// modification date
    public var updated: Date

    /// entry URL
    public var url: URL?

    /// entry content
    public var content: String?

    /// entry summary
    public var summary: String?

    /**default initializer.
    - Parameters:
        - id: entry identifier (defaults to UUID string)
        - title: entry title.
        - author: Author information
        - updated: The last time the entry was updated
        - url: entry URL (aka. the alternate)
        - content: Entry content
        - summary: Entry summary
    - Returns: AtomFeedEntry?
    - Note: either content or both url and summary **must not** be nil, otherwise initialization will fail.
    */
    public init?(id: String = UUID().uuidString, title: String, author: AtomFeedAuthor, updated: Date = Date(), url: URL? = nil, content: String? = nil, summary: String? = nil) {
        guard content != nil || url != nil && summary != nil else { return nil }

        ID = id
        self.title = title
        self.author = author
        self.updated = updated
        self.url = url
        self.content = content
        self.summary = summary
    }

    // implement function that allows comparisons to be made
    public static func ==(lhs: AtomFeedEntry, rhs: AtomFeedEntry) -> Bool {
        return lhs.ID == rhs.ID
    }

    /// return entry as XML
    public func xml() -> XMLElement {

        // create ISO8601DateFormatter, for RFC 3339 compliance
        let RFC3339_DF = ISO8601DateFormatter()

        // create entry element
        let ENTRY = XMLElement(name: "entry")

        // retrieve required items
        let ID = XMLElement(name: "id")
        if self.ID.hasPrefix("https://") || self.ID.hasPrefix("http://") {
            ID.stringValue = self.ID
        } else {
            ID.stringValue = "urn:uuid:\(self.ID.lowercased())"
        }
        
        let TITLE = XMLElement(name: "title", stringValue: title)
        let UPDATED = XMLElement(name: "updated", stringValue: RFC3339_DF.string(from: updated))
        
        // add required elemented to element
        ENTRY.addChild(ID)
        ENTRY.addChild(TITLE)
        ENTRY.addChild(author.xml())
        ENTRY.addChild(UPDATED)

        if let content = content {
            let CONTENT = XMLElement(name: "content", stringValue: content)
            CONTENT.setAttributesWith(["type": "html"])
            ENTRY.addChild(CONTENT)
        } else if let url = url, let summary = summary {
            let SUMMARY = XMLElement(name: "summary", stringValue: summary)
            let ALTERNATE = XMLElement(name: "link")
            ALTERNATE.setAttributesWith(["rel": "alternate", "href": url.absoluteString])
            ENTRY.addChild(SUMMARY)
            ENTRY.addChild(ALTERNATE)
        }
        
        return ENTRY
    }
}