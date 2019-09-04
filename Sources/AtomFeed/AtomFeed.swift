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

        // set up date formatter, for proper date formatting
        let RFC3339_DF = ISO8601DateFormatter()

        // create the root element
        let ROOT_ELEMENT = XMLElement(name: "feed")
        ROOT_ELEMENT.setAttributesWith(["xmlns": "http://www.w3.org/2005/Atom"])
        
        // create an XML document
        let XML = XMLDocument(rootElement: ROOT_ELEMENT)

        // create elements and add them to document
        let ID = XMLElement(name: "id")

        // check if ID has http:// or https:// prefix and set ID accordingly
        if self.ID.hasPrefix("https://") || self.ID.hasPrefix("http://") {
            ID.stringValue = self.ID
        } else {
            ID.stringValue = "urn:uuid:\(self.ID.lowercased())"
        }
        ROOT_ELEMENT.addChild(ID)

        // continue adding required or spec recommended elements
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

        // add some optional elements, if they are present
        if let icon = icon {
            let ICON = XMLElement(name: "icon", stringValue: icon.absoluteString)
            ROOT_ELEMENT.addChild(ICON)
        }

        if let logo = logo {
            let LOGO = XMLElement(name: "logo", stringValue: logo.absoluteString)
            ROOT_ELEMENT.addChild(LOGO)
        }

        // add entries to feed
        for entry in entries {
            ROOT_ELEMENT.addChild(entry.xml())
        }

        // return XMl data
        return XML.xmlData(options: [.nodePrettyPrint])
    }

    /**retrieve feed XML as string
    */
    public func display() -> String? {
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