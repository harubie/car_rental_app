// app/javascript/controllers/map_controller.js
import { Controller } from "@hotwired/stimulus"
import mapboxgl from 'mapbox-gl' // Don't forget this!

export default class extends Controller {
  static values = {
    apiKey: String,
    markers: Array
  }

  connect() {
    mapboxgl.accessToken = this.apiKeyValue

    // this.map is just like @map in a ruby object
    // we define it as this.map so we can access in other methods in this class
    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v10"
    })

    this.map.on('load', () => {
    // Loop through the array of markers and add each to the map
      this.addMarkersToMap()
      this.fitMapToMarkers()
    })
  }

  addMarkersToMap() {
    this.markersValue.forEach(markerJSON => {
      // markerJSON = { lat: 0.0, lng: 0.0 }
      new mapboxgl.Marker()
          .setLngLat([markerJSON.lng, markerJSON.lat])
          .addTo(this.map);
    });
  }

  fitMapToMarkers() {
    const bounds = new mapboxgl.LngLatBounds()
    this.markersValue.forEach(marker => bounds.extend([ marker.lng, marker.lat ]))
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 15, duration: 0 })
  }
}
