//
//  ViewController.swift
//  SBProgressHUD-Demo
//
//  Created by Max on 2023/7/5.
//

import SBProgressHUD
import UIKit

struct Example {
    let titleText: String?
    let selector: Selector?
}

class ViewController: UITableViewController {
    var examples = [[Example]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "SBProgressHUD Example"

        self.examples = [
            [
                Example(titleText: "Activity indicator style", selector: #selector(self.activityIndicatorStyleExample)),
                Example(titleText: "Activity indicator style with title text", selector: #selector(self.activityIndicatorStyleWithTitleTextExample)),
                Example(titleText: "Activity indicator style with details text", selector: #selector(self.activityIndicatorStyleWithDetailsTextExample)),
            ],
            [
                Example(titleText: "Linear progress style", selector: #selector(self.linearProgressStyleExample)),
                Example(titleText: "Doughnut progress style", selector: #selector(self.doughnutProgressStyleExample)),
                Example(titleText: "Pie progress style", selector: #selector(self.pieProgressStyleExample)),
                Example(titleText: "Linear progress style use NSProgress", selector: #selector(self.linearProgressStyleUseNSProgressExample)),
            ],
            [
                Example(titleText: "Text label style", selector: #selector(self.textLabelStyleExample)),
            ],
            [
                Example(titleText: "Custom view style", selector: #selector(self.customViewStyleExample)),
            ],
            [
                Example(titleText: "On window", selector: #selector(self.onWindowExample)),
                Example(titleText: "Style switching", selector: #selector(self.styleSwitchingExample)),
                Example(titleText: "Networking", selector: #selector(self.networkingExample)),
                Example(titleText: "Color", selector: #selector(self.colorExample)),
                Example(titleText: "Adjust background color", selector: #selector(self.adjustBackgroundColorExample)),
            ],
        ]
    }

    private func doSomeWork() {
        sleep(3)
    }

    private func doSomeWorkWithProgressObject(_ progressObject: Progress) {
        while progressObject.fractionCompleted < 1.0 {
            guard !progressObject.isCancelled else {
                break
            }

            progressObject.becomeCurrent(withPendingUnitCount: 1)
            progressObject.resignCurrent()

            usleep(50000)
        }
    }

    private func doSomeWorkWithProgress(_ progressCallback: @escaping (Float) -> Void) {
        var progress: Float = 0.0
        while progress < 1.0 {
            progress += 0.01

            DispatchQueue.main.async {
                progressCallback(progress)
            }

            usleep(50000)
        }
    }

    private func doSomeNetworkWorkWithProgress() {
        let configuration = URLSessionConfiguration.default

        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)

        var request = URLRequest(url: URL(string: "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4")!)
        request.httpMethod = "GET"

        let downloadTask = session.downloadTask(with: request)

        downloadTask.resume()
    }

    @objc
    func activityIndicatorStyleExample() {
        let progressHUD = SBProgressHUD.showProgressHUD(onView: self.navigationController?.view, animated: true)

        DispatchQueue.global(qos: .userInitiated).async {
            self.doSomeWork()

            DispatchQueue.main.async {
                progressHUD.hideProgressHUD(animated: true)
            }
        }
    }

    @objc
    func activityIndicatorStyleWithTitleTextExample() {
        let progressHUD = SBProgressHUD.showProgressHUD(onView: self.navigationController?.view, animated: true)
        progressHUD.titleText = "Loading..."

        DispatchQueue.global(qos: .userInitiated).async {
            self.doSomeWork()

            DispatchQueue.main.async {
                progressHUD.hideProgressHUD(animated: true)
            }
        }
    }

    @objc
    func activityIndicatorStyleWithDetailsTextExample() {
        let progressHUD = SBProgressHUD.showProgressHUD(onView: self.navigationController?.view, animated: true)
        progressHUD.titleText = "Loading..."
        progressHUD.detailsText = "Parsing data\n(1/1)"

        DispatchQueue.global(qos: .userInitiated).async {
            self.doSomeWork()

            DispatchQueue.main.async {
                progressHUD.hideProgressHUD(animated: true)
            }
        }
    }

    @objc
    func linearProgressStyleExample() {
        let progressHUD = SBProgressHUD.showProgressHUD(onView: self.navigationController?.view, animated: true)
        progressHUD.style = .linearProgress
        progressHUD.titleText = "Loading..."

        DispatchQueue.global(qos: .userInitiated).async {
            self.doSomeWorkWithProgress { progress in
                DispatchQueue.main.async {
                    progressHUD.progress = progress
                }
            }

            DispatchQueue.main.async {
                progressHUD.hideProgressHUD(animated: true)
            }
        }
    }

    @objc
    func doughnutProgressStyleExample() {
        let progressHUD = SBProgressHUD.showProgressHUD(onView: self.navigationController?.view, animated: true)
        progressHUD.style = .doughnutProgress
        progressHUD.titleText = "Loading..."

        DispatchQueue.global(qos: .userInitiated).async {
            self.doSomeWorkWithProgress { progress in
                DispatchQueue.main.async {
                    progressHUD.progress = progress
                }
            }

            DispatchQueue.main.async {
                progressHUD.hideProgressHUD(animated: true)
            }
        }
    }

    @objc
    func pieProgressStyleExample() {
        let progressHUD = SBProgressHUD.showProgressHUD(onView: self.navigationController?.view, animated: true)
        progressHUD.style = .pieProgress
        progressHUD.titleText = "Loading..."

        DispatchQueue.global(qos: .userInitiated).async {
            self.doSomeWorkWithProgress { progress in
                DispatchQueue.main.async {
                    progressHUD.progress = progress
                }
            }

            DispatchQueue.main.async {
                progressHUD.hideProgressHUD(animated: true)
            }
        }
    }

    @objc
    func linearProgressStyleUseNSProgressExample() {
        let progressHUD = SBProgressHUD.showProgressHUD(onView: self.navigationController?.view, animated: true)
        progressHUD.style = .linearProgress
        progressHUD.titleText = "Loading..."

        let progressObject = Progress(totalUnitCount: 100)
        progressHUD.progressObject = progressObject

        DispatchQueue.global(qos: .userInitiated).async {
            self.doSomeWorkWithProgressObject(progressObject)

            DispatchQueue.main.async {
                progressHUD.hideProgressHUD(animated: true)
            }
        }
    }

    @objc
    func textLabelStyleExample() {
        let progressHUD = SBProgressHUD.showProgressHUD(onView: self.navigationController?.view, animated: true)
        progressHUD.style = .textLabel
        progressHUD.titleText = "Hello Choiwan!"
        progressHUD.detailsText = "Easy to use translucent HUD framework for iOS with indicators and/or labels"
        progressHUD.offset = UIOffset(horizontal: 0.0, vertical: .greatestFiniteMagnitude)

        progressHUD.delayHideProgressHUD(3.0, animated: true)
    }

    @objc
    func customViewStyleExample() {
        let customImageView = UIImageView(image: UIImage(named: "icon_completion")?.withRenderingMode(.alwaysTemplate))

        let progressHUD = SBProgressHUD.showProgressHUD(onView: self.navigationController?.view, animated: true)
        progressHUD.style = .customView
        progressHUD.titleText = "Hello Choiwan!"
        progressHUD.customView = customImageView

        progressHUD.delayHideProgressHUD(3.0, animated: true)
    }

    @objc
    func onWindowExample() {
        let progressHUD = SBProgressHUD.showProgressHUD(onView: self.view.window, animated: true)

        DispatchQueue.global(qos: .userInitiated).async {
            self.doSomeWork()

            DispatchQueue.main.async {
                progressHUD.hideProgressHUD(animated: true)
            }
        }
    }

    @objc
    func styleSwitchingExample() {
        let progressHUD = SBProgressHUD.showProgressHUD(onView: self.navigationController?.view, animated: true)
        progressHUD.titleText = "Preparing..."
        progressHUD.minimumSize = CGSize(width: 150.0, height: 100.0)

        DispatchQueue.global(qos: .userInitiated).async {
            sleep(2)

            DispatchQueue.main.async {
                progressHUD.style = .doughnutProgress
                progressHUD.titleText = "Loading..."
            }

            var progress: Float = 0.0
            while progress < 1.0 {
                progress += 0.01

                DispatchQueue.main.async {
                    progressHUD.progress = progress
                }

                usleep(50000)
            }

            DispatchQueue.main.async {
                progressHUD.style = .activityIndicator
                progressHUD.titleText = "Cheaning up..."
            }

            sleep(2)

            DispatchQueue.main.async {
                let customImageView = UIImageView(image: UIImage(named: "icon_completion")?.withRenderingMode(.alwaysTemplate))

                progressHUD.style = .customView
                progressHUD.titleText = "Completed"
                progressHUD.customView = customImageView
            }

            sleep(2)

            DispatchQueue.main.async {
                progressHUD.hideProgressHUD(animated: true)
            }
        }
    }

    @objc
    func networkingExample() {
        let progressHUD = SBProgressHUD.showProgressHUD(onView: self.navigationController?.view, animated: true)
        progressHUD.titleText = "Preparing..."
        progressHUD.minimumSize = CGSize(width: 150.0, height: 100.0)

        self.doSomeNetworkWorkWithProgress()
    }

    @objc
    func colorExample() {
        let progressHUD = SBProgressHUD.showProgressHUD(onView: self.navigationController?.view, animated: true)
        progressHUD.color = UIColor(red: 0.71, green: 0.12, blue: 0.87, alpha: 1.0)
        progressHUD.titleText = "Loading..."

        DispatchQueue.global(qos: .userInitiated).async {
            self.doSomeWork()

            DispatchQueue.main.async {
                progressHUD.hideProgressHUD(animated: true)
            }
        }
    }

    @objc
    func adjustBackgroundColorExample() {
        let progressHUD = SBProgressHUD.showProgressHUD(onView: self.navigationController?.view, animated: true)
        progressHUD.backgroundViewColor = UIColor(white: 0.0, alpha: 0.2)

        DispatchQueue.global(qos: .userInitiated).async {
            self.doSomeWork()

            DispatchQueue.main.async {
                progressHUD.hideProgressHUD(animated: true)
            }
        }
    }
}

extension ViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.examples.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.examples[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpiritCell", for: indexPath)

        let example = self.examples[indexPath.section][indexPath.row]

        if #available(iOS 14.0, *) {
            var contentConfiguration = cell.defaultContentConfiguration()

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            contentConfiguration.attributedText = example.titleText.flatMap { NSAttributedString(string: $0, attributes: [.font: UIFont.systemFont(ofSize: 17.0), .paragraphStyle: paragraphStyle, .foregroundColor: UIColor(dynamicProvider: { $0.userInterfaceStyle == .light ? UIColor.black : UIColor.white })]) }
            cell.contentConfiguration = contentConfiguration
        } else {
            cell.textLabel?.text = example.titleText
            cell.textLabel?.font = UIFont.systemFont(ofSize: 17.0)
            if #available(iOS 13.0, *) {
                cell.textLabel?.textColor = UIColor(dynamicProvider: { $0.userInterfaceStyle == .light ? UIColor.black : UIColor.white })
            } else {
                cell.textLabel?.textColor = UIColor.black
            }
            cell.textLabel?.textAlignment = .center
        }

        return cell
    }
}

extension ViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let example = self.examples[indexPath.section][indexPath.row]

        self.perform(example.selector)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

extension ViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        DispatchQueue.main.async {
            let customImageView = UIImageView(image: UIImage(named: "icon_completion")?.withRenderingMode(.alwaysTemplate))

            let progressHUD = SBProgressHUD.getProgressHUD(fromView: self.navigationController?.view)
            progressHUD!.style = .customView
            progressHUD!.titleText = "Completed"
            progressHUD!.customView = customImageView

            progressHUD!.delayHideProgressHUD(3.0, animated: true)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)

        DispatchQueue.main.async {
            let progressHUD = SBProgressHUD.getProgressHUD(fromView: self.navigationController?.view)
            progressHUD?.style = .linearProgress
            progressHUD?.progress = progress
            progressHUD?.titleText = "Downloading..."
        }
    }
}
