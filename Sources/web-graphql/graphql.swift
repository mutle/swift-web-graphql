// Based on https://github.com/ZewoGraveyard/GraphQLResponder
import Foundation
import Graphiti
import web

public let noRootValue: Void = Void()

public class GraphQLResponder<Root, Context> : WebResponder {
  public let schema: Schema<Root, Context>
  public let rootValue: Root
  public let context: Context?

  public init(schema: Schema<Root, Context>, rootValue: Root, context: Context? = nil) {
    self.schema = schema
    self.rootValue = rootValue
    self.context = context
  }

  public func respond(to request: WebRequest) throws -> WebResponse? {
    var query: String? = nil
    var variables: [String: GraphQL.Map]? = nil
    var operationName: String? = nil
    var raw: Bool? = nil

    loop: for (name, value) in request.queryItems {
      switch name {
      case "query":
        query = value
      case "variables":
        // TODO: parse variables as JSON
        break
      case "operationName":
        operationName = value
      case "raw":
        raw = value.flatMap({ Bool($0) })
      default:
        continue loop
      }
    }
    guard let graphQLQuery = query else {
      return WebResponse(status: .badRequest, body: WebBody(string: "Must provide query string."))
    }

    let result: GraphQL.Map

    if Context.self is WebRequest.Type && context == nil {
      result = try schema.execute(
        request: graphQLQuery,
        rootValue: rootValue,
        context: request as! Context,
        variables: variables ?? [:],
        operationName: operationName
      )
    } else if let context = context {
      result = try schema.execute(
        request: graphQLQuery,
        rootValue: rootValue,
        context: context,
        variables: variables ?? [:],
        operationName: operationName
      )
    } else {
      result = try schema.execute(
        request: graphQLQuery,
        rootValue: rootValue,
        variables: variables ?? [:],
        operationName: operationName
      )
    }

    if let data = convert(map: result) as? [String : Any] {
      return WebResponse(status: .ok, body: WebBody(json: data))
    }
    return nil
  }

  func convert(map: GraphQL.Map) -> Any? {
    switch map {
    case .null:
        return nil
    case .bool(let bool):
        return bool
    case .double(let double):
        return double
    case .int(let int):
        return int
    case .string(let string):
        return string
    case .array(let array):
        return array.map({ convert(map: $0) })
    case .dictionary(let dictionary):
        var dict: [String: Any] = [:]
        for (key, value) in dictionary {
          dict[key] = convert(map: value)
        }
        return dict
    }
  }
}
