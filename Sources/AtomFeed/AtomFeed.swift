import Foundation

/**AtomFeed is a model that represents Atom feeds, with methods to help easily create AtomFeeds
*/
public class AtomFeed: Equatable {

    /// feed identifier
    public let ID: String

    /// feed title
    public var title: String

    /// feed description
    public var subtitle: String?

    /// feed author
    public var author: AtomFeedAuthor

    /// feed modification date
    public var updated: Date

    /// URL where content comes from
    public var homePage: URL

    /// feed url
    public var url: URL?

    /// icon URL
    public var icon: URL?

    /// logo URL
    public var logo: URL?

    /// array of entries
    public var entries: [AtomFeedEntry]

    /**Default initializer
    - Parameters:
        - id: feed identifier (defaults to UUID string)
        - title: feed title.
        - subtitle: feed description (optional).
        - homePage: main website.
        - url: feed URL (optional)
        - icon: location of icon (optional).
        - logo: location of logo (optional).
        - entries: array of feed entries (defaults to empty array).
    - Returns: AtomFeed
    */
    public init(withID id: String = UUID().uuidString, title: String, subtitle: String? = nil, author: AtomFeedAuthor, homePage: URL, url: URL? = nil, updated: Date = Date(), icon: URL? = nil, logo: URL? = nil, entries: [AtomFeedEntry] = [AtomFeedEntry]()) {
        ID = id
        self.title = title
        self.subtitle = subtitle
        self.author = author
        self.homePage = homePage
        self.url = url
        self.updated = updated
        self.icon = icon
        self.logo = logo
        self.entries = entries
    }

    // implement function to allow comparing feeds
    public static func ==(lhs: AtomFeed, rhs: AtomFeed) -> Bool {
        return lhs.ID == rhs.ID
    }

    // the following function is used to produce XML output
    private func xml() -> Data {
        let RFC3339_DF = ISO8601DateFormatter()
        let ROOT_ELEMENT = XMLElement(name: "feed")
        ROOT_ELEMENT.setAttributesWith(["xmlns": "http://www.w3.org/2005/Atom"])
        
        let XML = XMLDocument(rootElement: ROOT_ELEMENT)

        let ID = XMLElement(name: "id")

        if self.ID.hasPrefix("https://") || self.ID.hasPrefix("http://") {
            ID.stringValue = self.ID
        } else {
            ID.stringValue = "urn:uuid:\(self.ID.lowercased())"
        }
        ROOT_ELEMENT.addChild(ID)

        let TITLE = XMLElement(name: "title", stringValue: title)
        ROOT_ELEMENT.addChild(TITLE)
        
        let HOME_PAGE = XMLElement(name: "link")
        HOME_PAGE.setAttributesWith(["href": homePage.absoluteString])
        ROOT_ELEMENT.addChild(HOME_PAGE)

        if let url = url {
            let FEED_URL = XMLElement(name: "link")
            FEED_URL.setAttributesWith(["rel": "self", "href": url.absoluteString])
            ROOT_ELEMENT.addChild(FEED_URL)
        }

        let UPDATED = XMLElement(name: "updated", stringValue: RFC3339_DF.string(from: updated))
        ROOT_ELEMENT.addChild(UPDATED)

        if let icon = icon {
            let ICON = XMLElement(name: "icon", stringValue: icon.absoluteString)
            ROOT_ELEMENT.addChild(ICON)
        }

        if let logo = logo {
            let LOGO = XMLElement(name: "logo", stringValue: logo.absoluteString)
            ROOT_ELEMENT.addChild(LOGO)
        }

        for entry in entries.reversed() {
            ROOT_ELEMENT.addChild(entry.xml())
        }

        return XML.xmlData(options: [.nodePrettyPrint])
    }

    /**Display feed as XML
    */
    public func output() -> String? {
        guard let xml = String(data: xml(), encoding: .utf8) else { return nil }

        return xml
    }

    /** Save feed to file
    - Parameter path: location to save file.
    */
    public func save(to path: URL) {
        #if os(iOS) || os(watchOS) || os(tvOS)
            try? xml().write(to: path, options: .noFileProtection)
        #else
            try? xml().write(to: path, options: .atomic)
        #endif
    }
}