//
//  ChatBirdMessageDecorator.swift
//  ChatBird
//
//  Adapted from Chatto sample app
//  https://github.com/badoo/Chatto
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015-present Badoo Trading Limited.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
 

import Foundation
import Chatto
import ChattoAdditions
import SendBirdSDK

public final class ChatBirdMessageDecorator: ChatItemsDecoratorProtocol {

    let channel: SBDGroupChannel
    public init(channel: SBDGroupChannel) {
        self.channel = channel
    }

    private struct Constants {
        static let shortSeparation: CGFloat = 3
        static let normalSeparation: CGFloat = 3
        static let timeIntervalThresholdToIncreaseSeparation: TimeInterval = 120
    }

    public func decorateItems(_ chatItems: [ChatItemProtocol]) -> [DecoratedChatItem] {
        var decoratedChatItems = [DecoratedChatItem]()
        let calendar = Calendar.current
        let chatMessages = chatItems.compactMap { $0 as? MessageModelProtocol }

        for (index, chatItem) in chatItems.enumerated() {
            let next: ChatItemProtocol? = (index + 1 < chatItems.count) ? chatItems[index + 1] : nil
            let prev: ChatItemProtocol? = (index > 0) ? chatItems[index - 1] : nil

            let isLastOutgoing = chatItem.uid == chatMessages.last(where: { !$0.isIncoming })?.uid

            let bottomMargin = self.separationAfterItem(chatItem, next: next, isLastOutgoing: isLastOutgoing)
            var additionalItems =  [DecoratedChatItem]()
            var addTimeSeparator = false
            var addName = false
            var isSelected = false
            var showAvatar = false
            var isShowingSelectionIndicator = false

            if let currentMessage = chatItem as? MessageModelProtocol {

                if let nextMessage = next as? MessageModelProtocol {
                    showAvatar = currentMessage.senderId != nextMessage.senderId
                } else {
                    showAvatar = currentMessage.isIncoming
                }

                if let previousMessage = prev as? MessageModelProtocol {
                    addTimeSeparator = !calendar.isDate(currentMessage.date, inSameDayAs: previousMessage.date)

                    if previousMessage.senderId != currentMessage.senderId, currentMessage.isIncoming {
                        addName = true
                    }

                } else {
                    addTimeSeparator = true
                    addName = currentMessage.isIncoming
                }

                if isLastOutgoing, let message = currentMessage as? UserMessageType {
                    additionalItems.append(
                        DecoratedChatItem(
                            chatItem: SendingStatusModel(uid: "\(currentMessage.uid)-decoration-status", status: currentMessage.status, isMultiUserGroup: (channel.members?.count ?? 0) > 2, seenCount: message.readCount(for: channel)),
                            decorationAttributes: nil)
                    )
                }

                if addTimeSeparator {
                    let dateTimeStamp = DecoratedChatItem(chatItem: TimeSeparatorModel(uid: "\(currentMessage.uid)-time-separator", date: currentMessage.date.toWeekDayAndDateString()), decorationAttributes: nil)
                    decoratedChatItems.append(dateTimeStamp)
                }

                if addName, let name = (currentMessage as? UserMessageType)?.sender?.displayName {
                    decoratedChatItems.append(
                        DecoratedChatItem(
                            chatItem: NameModel(uid: "\(currentMessage.uid)-decoration-name", name: name),
                            decorationAttributes: nil)
                    )
                }

                isSelected = false
                isShowingSelectionIndicator = false
            }

            let messageDecorationAttributes = BaseMessageDecorationAttributes(
                canShowFailedIcon: true,
                isShowingTail: false,
                isShowingAvatar: showAvatar,
                isShowingSelectionIndicator: isShowingSelectionIndicator,
                isSelected: isSelected
            )

            decoratedChatItems.append(
                DecoratedChatItem(
                    chatItem: chatItem,
                    decorationAttributes: ChatItemDecorationAttributes(bottomMargin: bottomMargin, messageDecorationAttributes: messageDecorationAttributes)
                )
            )
            decoratedChatItems.append(contentsOf: additionalItems)
        }

        return decoratedChatItems
    }

    private func separationAfterItem(_ current: ChatItemProtocol?, next: ChatItemProtocol?, isLastOutgoing: Bool) -> CGFloat {
        guard let nexItem = next else { return 0 }
        guard let currentMessage = current as? MessageModelProtocol else { return Constants.normalSeparation }
        guard let nextMessage = nexItem as? MessageModelProtocol else { return Constants.normalSeparation }

        if isLastOutgoing {
            return 0
        } else if currentMessage.senderId != nextMessage.senderId {
            return Constants.normalSeparation
        } else if nextMessage.date.timeIntervalSince(currentMessage.date) > Constants.timeIntervalThresholdToIncreaseSeparation {
            return Constants.normalSeparation
        } else {
            return Constants.shortSeparation
        }
    }
}
