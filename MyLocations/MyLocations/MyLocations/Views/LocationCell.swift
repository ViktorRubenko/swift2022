//
//  LocationCell.swift
//  MyLocations
//
//  Created by Victor Rubenko on 21.02.2022.
//

import UIKit

class LocationCell: UITableViewCell {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(for location: Location) {
        descLabel.text = location.locationDescription.isEmpty ? "" : location.locationDescription
        
        if let placemark = location.placemark {
            var text = ""
            if let tmp = placemark.subThoroughfare {
                text += tmp + " "
            }
            if let tmp = placemark.thoroughfare {
                text += tmp + ", "
            }
            if let tmp = placemark.locality {
                text += tmp
            }
            addressLabel.text = text
        } else {
            addressLabel.text = String(
                format: "Lat: %.8f, Lon: %.8f",
                location.latitude,
                location.longitude
            )
        }
    }

}
