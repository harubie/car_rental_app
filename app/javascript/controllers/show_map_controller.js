import { Controller } from "@hotwired/stimulus"
import mapboxgl from 'mapbox-gl'

// Connects to data-controller="show-map"
export default class extends Controller {
  static values = {
  apiKey: String,
  latitude: Number,
  longitude: Number
}

  connect() {
    mapboxgl.accessToken = this.apiKeyValue

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v12",
      center: [this.longitudeValue, this.latitudeValue],
      zoom: 13
    })

    new mapboxgl.Marker()
      .setLngLat([this.longitudeValue, this.latitudeValue])
      .addTo(this.map)
  }
}
