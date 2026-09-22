/* CFL Forensics - installer slideshow (Calamares 3.3 Presentation API) */
import QtQuick 2.0
import calamares.slideshow 1.0

Presentation {
    id: presentation

    Timer {
        interval: 8000
        running: true
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    Slide {
        Image {
            source: "slide1.png"
            anchors.centerIn: parent
            width: parent.width; height: parent.height
            fillMode: Image.PreserveAspectFit
        }
    }
    Slide {
        Image {
            source: "slide2.png"
            anchors.centerIn: parent
            width: parent.width; height: parent.height
            fillMode: Image.PreserveAspectFit
        }
    }
}
