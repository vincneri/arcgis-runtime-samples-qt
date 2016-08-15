// [WriteFile Name=OfflineGeocode, Category=Search]
// [Legal]
// Copyright 2016 Esri.

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

#ifndef OFFLINEGEOCODE_H
#define OFFLINEGEOCODE_H

namespace Esri
{
    namespace ArcGISRuntime
    {
        class Map;
        class MapQuickView;
        class ArcGISTiledLayer;
    }
}

#include <QQuickItem>

class OfflineGeocode : public QQuickItem
{
    Q_OBJECT

public:
    OfflineGeocode(QQuickItem* parent = nullptr);
    ~OfflineGeocode();

    void componentComplete() Q_DECL_OVERRIDE;

private:
    QString m_dataPath;
    Esri::ArcGISRuntime::Map* m_map;
    Esri::ArcGISRuntime::MapQuickView* m_mapView;
    Esri::ArcGISRuntime::ArcGISTiledLayer* m_tiledLayer;
};

#endif // OFFLINEGEOCODE_H
