/*
 * Copyright 2017 Google Inc. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0 (the "License")
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * Base class for all Blockly events.
 */
@objc(BKYBlocklyEvent)
public class BlocklyEvent: NSObject {

  // MARK: - Properties

  /// Data type used for specifying a type of BlocklyEvent.
  public typealias EventType = String

  // JSON serialization attributes.  See also TYPENAME_ and ELEMENT_ constants for ids.
  internal static let JSON_BLOCK_ID = "blockId"
  internal static let JSON_ELEMENT = "element"
  internal static let JSON_GROUP_ID = "groupId"
  internal static let JSON_IDS = "ids"
  internal static let JSON_NAME = "name"
  internal static let JSON_NEW_VALUE = "newValue"
  internal static let JSON_OLD_VALUE = "oldValue"  // Rarely used.
  internal static let JSON_TYPE = "type"
  internal static let JSON_WORKSPACE_ID = "workspaceId" // Rarely used.
  internal static let JSON_XML = "xml"

  /// The type of this event.
  public let type: EventType
  /// The ID for the workspace that triggered this event.
  public let workspaceID: String
  /// The ID for the group of related events.
  public let groupID: String?
  /// The ID of the primary or root affected block.
  public let blockID: String?

  // MARK: - Initializers

  /**
   Creates a `BlocklyEvent`.

   - parameter type: The `EventType`.
   - parameter workspaceID: The ID string of the Blockly workspace.
   - parameter groupID: The ID string of the event group. Usually `nil` for local events (assigned
     later) and non-`nil` for remote events.
   - parameter blockID: The ID string of the block affected. `nil` for a few event types
     (e.g. toolbox category).
   */
  public init(type: EventType, workspaceID: String, groupID: String?, blockID: String?) {
    self.type = type
    self.workspaceID = workspaceID
    self.groupID = groupID
    self.blockID = blockID
  }

  /**
   Constructs a `BlocklyEvent` with base attributes assigned from JSON.

   - parameter type: The type of the event.
   - parameter json: The JSON object with event attribute values.
   - throws:
   `BlocklyError`: Thrown if `BlocklyEvent.JSON_WORKSPACE_ID` is not specified as a key within the
   given `json`.
   */
  public init(type: EventType, json: [String: Any]) throws {
    self.type = type
    if let workspaceID = json[BlocklyEvent.JSON_WORKSPACE_ID] as? String {
      self.workspaceID = workspaceID
    } else {
      throw BlocklyError(.jsonParsing,
                         "Must supply \"\(BlocklyEvent.JSON_WORKSPACE_ID)\" in JSON event")
    }
    self.groupID = json[BlocklyEvent.JSON_GROUP_ID] as? String
    self.blockID = json[BlocklyEvent.JSON_BLOCK_ID] as? String
  }

  // MARK: - JSON Serialization

  /**
   Returns a JSON dictionary serialization of the event.

   - returns: A JSON dictionary serialization of the event.
   - throws:
   `BlocklyError`: Thrown if the event could not be serialized.
   */
  public func toJSON() throws -> [String: Any] {
    var json = [String: Any]()
    json[BlocklyEvent.JSON_TYPE] = type
    json[BlocklyEvent.JSON_WORKSPACE_ID] = workspaceID

    if let blockID = self.blockID {
      json[BlocklyEvent.JSON_BLOCK_ID] = blockID
    }

    if let groupID = self.groupID {
      json[BlocklyEvent.JSON_GROUP_ID] = groupID
    }

    return json
  }

  /**
   Calls `self.toJSON()` and returns a string representation of that JSON dictionary.

   - returns: A JSON string representation of the event.
   - throws:
   `BlocklyError`: Thrown if the event could not be serialized.
   */
  public final func toJSONString() throws -> String {
    let data = try JSONSerialization.data(withJSONObject: toJSON())
    if let jsonString = String(data: data, encoding: .utf8) {
      return jsonString
    } else {
      throw BlocklyError(.jsonSerialization, "Could not serialize `self.toJSON()` into a String.")
    }
  }
}