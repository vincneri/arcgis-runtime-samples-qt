// [WriteFile Name=StatisticalQuery, Category=Analysis]
// [Legal]
// Copyright 2017 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// [Legal]

import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import Esri.ArcGISRuntime 100.2
import Esri.ArcGISExtras 1.1

Rectangle {
    clip: true
    width: 800
    height: 600

    property url worldCitiesUrl: "https://sampleserver6.arcgisonline.com/arcgis/rest/services/SampleWorldCities/MapServer/0"
    property real scaleFactor: System.displayScaleFactor
    property alias extentOnly: extentCheckbox.checked
    property alias bigCitiesOnly: bigCitiesCheckbox.checked
    property string resultsText: ""

    MapView {
        id: mapView
        anchors.fill: parent

        // Create a new Map with the world streets vector basemap
        Map {
            BasemapStreetsVector {}

            // Create a new feature layer to display features in the world cities table
            FeatureLayer {
                // Create feature table using the world cities URL
                ServiceFeatureTable {
                    id: featureTable
                    url: worldCitiesUrl

                    // Setup signal handler for queryStatisticsStatusChanged signal
                    onQueryStatisticsStatusChanged: {
                        if (queryStatisticsStatus !== Enums.TaskStatusCompleted)
                            return;

                        // Reset the result text
                        resultsText = "";

                        // Iterate through the results
                        var iter = queryStatisticsResult.iterator;
                        while (iter.hasNext) {
                            var record = iter.next();
                            for (var key in record.statistics) {
                                if (record.statistics.hasOwnProperty(key)) {
                                    resultsText += key + ": " + record.statistics[key] + "\n";
                                }
                            }
                        }

                        // Display the results
                        msgDialog.open();
                    }
                }
            }
        }
    }

    Rectangle {
        anchors {
            fill: controlColumn
            margins: -10 * scaleFactor
        }
        color: "#E9E9EA"
        radius: 3 * scaleFactor
        opacity: 0.8
        border {
            color: "black"
            width: 1 * scaleFactor
        }
    }

    Column {
        id: controlColumn
        anchors {
            left: parent.left
            top: parent.top
            margins: 15 * scaleFactor
        }
        spacing: 5 * scaleFactor

        CheckBox {
            id: extentCheckbox
            text: "Only cities in current extent"
        }

        CheckBox {
            id: bigCitiesCheckbox
            text: "Only cities greater than 5M"
        }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Get Statistics"
            onClicked: {
                // If only using features in the current extent, set up the spatial filter for the statistics query parameters
                if (extentOnly) {
                    // Set the statistics query parameters geometry with the envelope
                    queryParameters.geometry = mapView.currentViewpointExtent.extent;

                    // Set the spatial relationship to Intersects (which is the default)
                    queryParameters.spatialRelationship = Enums.SpatialRelationshipIntersects;
                } else {
                    // Reset the query parameters
                    queryParameters.geometry = null;
                }

                // If only evaluating the largest cities (over 5 million in population), set up an attribute filter
                if (bigCitiesOnly)
                    queryParameters.whereClause = "POP_RANK = 1";
                else
                    queryParameters.whereClause = "1=1";

                // Execute the statistical query with these parameters
                featureTable.queryStatistics(queryParameters);
            }
        }
    }

    // Declare a StatisticsQueryParameters object
    StatisticsQueryParameters {
        id: queryParameters

        // Add the Statistic Definitions
        StatisticDefinition { onFieldName: "POP"; statisticType: Enums.StatisticTypeAverage}
        StatisticDefinition { onFieldName: "POP"; statisticType: Enums.StatisticTypeMinimum}
        StatisticDefinition { onFieldName: "POP"; statisticType: Enums.StatisticTypeMaximum}
        StatisticDefinition { onFieldName: "POP"; statisticType: Enums.StatisticTypeSum}
        StatisticDefinition { onFieldName: "POP"; statisticType: Enums.StatisticTypeStandardDeviation}
        StatisticDefinition { onFieldName: "POP"; statisticType: Enums.StatisticTypeVariance}
        StatisticDefinition { onFieldName: "POP"; statisticType: Enums.StatisticTypeCount; outputAlias: "CityCount"}
    }

    // Create a dialog to display the result
    MessageDialog {
        id: msgDialog
        text: "Query Statistics Results:"
        informativeText: resultsText
    }
}
