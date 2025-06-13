import { Controller } from "@hotwired/stimulus";

/* stimulusFetch: 'lazy' */
export default class extends Controller {
    static values = { url: String };
    static targets = ["input"];

    lookup() {
        const code = this.inputTarget.value.trim();
        if (code === '') {
            return;
        }

        fetch(`${this.urlValue}?barcode=${encodeURIComponent(code)}`)
            .then(r => r.json())
            .then(data => {
                if (data.name) {
                    const el = document.querySelector("[name='part[name]']");
                    if (el) el.value = data.name;
                }
                if (data.mpn) {
                    const el = document.querySelector("[name='part[manufacturer_product_number]']");
                    if (el) el.value = data.mpn;
                }
                if (data.manufacturer) {
                    const el = document.querySelector("[name='part[manufacturer]']");
                    if (el) el.value = data.manufacturer;
                }
                if (data.datasheet) {
                    const el = document.querySelector("[name='part[manufacturer_product_url]']");
                    if (el) el.value = data.datasheet;
                } else if (data.product_url) {
                    const el = document.querySelector("[name='part[manufacturer_product_url]']");
                    if (el) el.value = data.product_url;
                }
            })
            .catch(() => {
                alert('Barcode lookup failed');
            });
    }
}
