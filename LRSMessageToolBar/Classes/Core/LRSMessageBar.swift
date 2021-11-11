//
//  LRSMessageBar.swift
//  LRSMessageToolBar
//
//  Created by sama 刘 on 2021/11/9.
//

import UIKit

enum Mode {
    case normal
    case keyboard
    case meme
}

@objc public class LRSMessageBar: UIView {

    private let configure: LRSMessageToolBarConfigure
    private let toolBar: LRSMessageInputBar
    private var mode: Mode = .normal
    private var memeBoardHeight: CGFloat = LRSMemePackagesView.boardHeight()

    @objc weak var delegate: LRSMesssageBarProtocol?

    private lazy var memePackagesView = LRSMemePackagesView(frame: .zero, configures: LRSMessageToolBarHelper.allEmojis())

    var textViewHeight: CGFloat {
        let textView = toolBar.inputTextView
        let height = textView.sizeThatFits(textView.bounds.size).height
        let minHeight = configure.textViewConfigure.minHeight
        let maxHeight = configure.textViewConfigure.maxHeight
        return min(maxHeight, max(minHeight, height))
    }

    @objc public init(frame: CGRect, configure: LRSMessageToolBarConfigure = .default()) {
        self.configure = configure
        toolBar = LRSMessageInputBar.toolBar(with: configure)
        super.init(frame: frame)
        buildUI()
        addObservers()
    }

    required init?(coder: NSCoder) {
        configure = .default()
        toolBar = LRSMessageInputBar.toolBar(with: configure)
        super.init(coder: coder)
        buildUI()
        addObservers()
    }

    private func buildUI() {
        toolBar.frame = CGRect(x: 0, y: 0, width: LRSMessageToolBarHelper.screenWidth(), height: self.textViewHeight)
        addSubview(toolBar)
        memePackagesView.buildUI()
        toolBar.faceButton.addTarget(self, action: #selector(onSwithMemeMode(button:)), for: .touchUpInside)
        toolBar.modeSwitchButton.addTarget(self, action: #selector(onSwithButtonClicked(button:)), for: .touchUpInside)
    }

    @objc func onSwithButtonClicked(button: UIButton) {
        switch toolBar.mode {
        case .record:
            mode = .normal
            toolBar.inputTextView.resignFirstResponder()
            animationHiddenMemePackagesView()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.animationResignFirstResponder(duration: 0.3)
            }
        case .textInput: break

        }
    }

    private func animationHiddenMemePackagesView() {
        UIView.animate(withDuration: 0.3) {
            var memeRect = self.memePackagesView.frame
            memeRect.origin.y = self.textViewHeight + 60
            self.memePackagesView.frame = memeRect
        }
    }

    private func animationResignFirstResponder(duration: TimeInterval) {
        let y = LRSMessageToolBarHelper.screenHeight() - self.textViewHeight - LRSMessageToolBarHelper.safeAreaHeight()
        var rect = self.frame
        rect.origin.y = y
        UIView.animate(withDuration: duration) {
            self.frame = rect
        }
    }

    private func animationShowMemePackagesView() {
        let height = self.textViewHeight + self.memeBoardHeight
        let rect = self.frame
        self.memePackagesView.frame = CGRect(x: 0, y: height, width: rect.size.width, height: self.memeBoardHeight)
        UIView.animate(withDuration: 0.3) {
            var memeRect = self.memePackagesView.frame
            memeRect.origin.y = self.textViewHeight + 10
            self.memePackagesView.frame = memeRect
        }
    }

    private func animationBecomeFirstResponder(duration: TimeInterval, bottomHeight: CGFloat) {
        let height = self.textViewHeight + bottomHeight + 10
        let y = LRSMessageToolBarHelper.screenHeight() - height
        var rect = self.frame
        rect.origin.y = y
        rect.size.height = height
        UIView.animate(withDuration: 0.3) {
            self.frame = rect
        }
    }

    @objc func onSwithMemeMode(button: UIButton) {
        if mode == .normal || mode == .keyboard {
            mode = .meme
            toolBar.inputTextView.resignFirstResponder()
            animationBecomeFirstResponder(duration: 0.3, bottomHeight: self.memeBoardHeight)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.animationShowMemePackagesView()
            }
        } else {
            toolBar.inputTextView.becomeFirstResponder()
            mode = .keyboard
            UIView.animate(withDuration: 0.3) {
                var memeRect = self.memePackagesView.frame
                memeRect.origin.y = self.textViewHeight + self.memeBoardHeight
                self.memePackagesView.frame = memeRect
            }
        }
    }

    private func addObservers() {
        toolBar.inputTextView.delegate = self

        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: .main) {[unowned self] noti in
            let info = noti.userInfo
            let duration = info?[UIKeyboardAnimationDurationUserInfoKey] as? Double
            let to = info?[UIKeyboardFrameEndUserInfoKey] as? CGRect
            animationBecomeFirstResponder(duration: duration ?? 0.3, bottomHeight: to?.size.height ?? 100)
            mode = .keyboard
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: .main) {[unowned self] noti in
            if mode == .keyboard {
                let info = noti.userInfo
                let duration = info?[UIKeyboardAnimationDurationUserInfoKey] as? Double
                animationResignFirstResponder(duration: duration ?? 0.3)
            }
        }
    }


    func sendMessage() {
        let str = toolBar.inputTextView.text.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")
        delegate?.messageToolBarDidClickedReturn(bar: self, text: str)
        toolBar.inputTextView.text = ""
        toolBar.inputTextView.setContentOffset(.zero, animated: true)
        toolBar.inputTextView.resignFirstResponder()
    }
}
//    - (LRSMemePackagesView *)memePackagesView {
//        if (!_memePackagesView) {
//            _memePackagesView = [[LRSMemePackagesView alloc] initWithFrame:CGRectZero configures:[LRSMessageToolBarHelper allEmojis]];
//            __weak typeof(self) weakSelf = self;
//            _memePackagesView.itemHandler = ^(LRSMemeSinglePage *view, LRSMemePackageConfigureItem *item) {
//                NSString *chatText = weakSelf.toolBar.inputTextView.text;
//                weakSelf.toolBar.inputTextView.text = [NSString stringWithFormat:@"%@%@", chatText ?: @"", item.emojiValue];
//                [weakSelf textViewDidChange:weakSelf.toolBar.inputTextView];
//            };
//            _memePackagesView.backspaceHandler = ^(LRSMemeSinglePage *view) {
//                [weakSelf.toolBar.inputTextView deleteBackward];
//            };
//            _memePackagesView.sendOutHandler = ^(LRSMemePackgaesView *view) {
//                [weakSelf sendOut_];
//            };
//        }
//        return _memePackagesView;
//    }
//
//    - (LRSMessageInputBar *)toolBar {
//        if (!_toolBar) {
//            _toolBar = [LRSMessageInputBar toolBarWithConfigure:self.configure];
//            _toolBar.backgroundColor = [UIColor whiteColor];
//            _toolBar.layer.shadowColor = [[UIColor blackColor] CGColor];
//            _toolBar.layer.shadowOffset = CGSizeMake(0, -2 * [LRSMessageToolBarHelper scale]);
//            _toolBar.layer.shadowRadius = 5.0 * [LRSMessageToolBarHelper scale];
//            _toolBar.layer.shadowOpacity = 0.1;
//            _toolBar.inputTextView.delegate = self;
//            __weak typeof(self) weakSelf = self;
//            _toolBar.recordingBtn.touchBegan = ^(LRSMessageToolBarRecordButton *button) {
//                NSLog(@"按下按钮,开始录音");
//                micphonePerPermission_ = [self.datasource audioPermission];
//                if (!micphonePerPermission_) {
//                    weakSelf.toolBar.recordingBtn.selected = false;
//                    return;
//                }
//                if (weakSelf.delegate && [self.delegate respondsToSelector:@selector(messageToolBarBeganToSpeak:)]) {
//                    [weakSelf.delegate messageToolBarBeganToSpeak:weakSelf];
//                }
//            };
//            _toolBar.recordingBtn.touchEnd = ^(LRSMessageToolBarRecordButton *button) {
//                NSLog(@"结束录音");
//                if ([weakSelf.delegate respondsToSelector:@selector(messageToolBarEndSpeaking:)]) {
//                    [weakSelf.delegate messageToolBarEndSpeaking:weakSelf];
//                }
//            };
//            _toolBar.recordingBtn.dragEnter = ^(LRSMessageToolBarRecordButton *button) {
//                NSLog(@"区域划入");
//                if ([weakSelf.delegate respondsToSelector:@selector(messageToolBarDragEnterRecordScope)]) {
//                    [weakSelf.delegate messageToolBarDragEnterRecordScope:weakSelf];
//                }
//            };
//            _toolBar.recordingBtn.dragOutside = ^(LRSMessageToolBarRecordButton *button) {
//                NSLog(@"区域划出");
//                if ([weakSelf.delegate respondsToSelector:@selector(messageToolBarDragOutRecordScope)]) {
//                    [weakSelf.delegate messageToolBarDragOutRecordScope:weakSelf];
//                }
//            };
//            _toolBar.recordingBtn.dragOutsideRelease = ^(LRSMessageToolBarRecordButton *button) {
//                NSLog(@"区域划出松手");
//                if ([weakSelf.delegate respondsToSelector:@selector(messageToolBarSlideTopToCancelRecording:)]) {
//                    [weakSelf.delegate messageToolBarSlideTopToCancelRecording:weakSelf];
//                }
//            };
//        }
//        return _toolBar;
//    }


extension LRSMessageBar: UITextViewDelegate {

    public func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.messageToolBarInputTextViewDidBeginEditing?(bar: self)
        UIView.animate(withDuration: 0.3) {
            var memeRect = self.memePackagesView.frame
            memeRect.origin.y = self.textViewHeight + self.memeBoardHeight
            self.memePackagesView.frame = memeRect
        }
    }

    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return delegate?.messageToolBarShouldBeginEditting(bar: self) ?? true
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.messageToolBarInputTextViewDidEndEditing(bar: self)
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {
        guard let end = textView.selectedTextRange?.end else {
            return
        }
        let r = textView.caretRect(for: end)
        let y = max(r.origin.y - textView.frame.size.height + r.size.height + 8, 0)
        if textView.contentOffset.y < y && r.origin.y != .infinity {
            textView.contentOffset = CGPoint(x: 0, y: y)
        }
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            sendMessage()
            return false
        }
        return true
    }

    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }

    public func textViewDidChange(_ textView: UITextView) {
        let length = configure.textViewConfigure.acceptLength
        guard textView.text.count < length else {
            return
        }
        textView.text = String(textView.text.prefix(length))
        // height
    }

}
