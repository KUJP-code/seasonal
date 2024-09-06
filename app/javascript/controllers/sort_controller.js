import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	static targets = ["toggle"];
	static values = { col: String, event: String };

	ascending(tableBody, colValue, rows) {
		if (colValue == ".school") {
			rows.sort(function (a, b) {
				return a.querySelector(colValue).innerHTML ==
					b.querySelector(colValue).innerHTML
					? 0
					: a.querySelector(colValue).innerHTML >
							b.querySelector(colValue).innerHTML
						? 1
						: -1;
			});
		} else {
			rows.sort(function (a, b) {
				let numA = parseInt(
					a.querySelector(colValue).innerHTML.replace(/[円,%]/g, ""),
				);
				let numB = parseInt(
					b.querySelector(colValue).innerHTML.replace(/[円,%]/g, ""),
				);
				return numA == numB ? 0 : numA > numB ? 1 : -1;
			});
		}

		for (let i = 0; i < rows.length; ++i) {
			tableBody.appendChild(rows[i]);
		}
	}

	descending(tableBody, colValue, rows) {
		if (colValue == ".school") {
			rows.sort(function (a, b) {
				return a.querySelector(colValue).innerHTML ==
					b.querySelector(colValue).innerHTML
					? 0
					: a.querySelector(colValue).innerHTML >
							b.querySelector(colValue).innerHTML
						? -1
						: 1;
			});
		} else {
			rows.sort(function (a, b) {
				let numA = parseInt(
					a.querySelector(colValue).innerHTML.replace(/[円,%]/g, ""),
				);
				let numB = parseInt(
					b.querySelector(colValue).innerHTML.replace(/[円,%]/g, ""),
				);
				return numA == numB ? 0 : numA > numB ? -1 : 1;
			});
		}

		for (let i = 0; i < rows.length; ++i) {
			tableBody.appendChild(rows[i]);
		}
	}

	sort() {
		const tableBody = document.getElementById(this.eventValue);
		const colValue = this.colValue;

		let rows = [...tableBody.children];

		if (this.toggleTarget.classList.contains("ascending")) {
			this.toggleTarget.classList.add("descending");
			this.toggleTarget.classList.remove("ascending");
			this.descending(tableBody, colValue, rows);
		} else {
			this.toggleTarget.classList.add("ascending");
			this.toggleTarget.classList.remove("descending");
			this.ascending(tableBody, colValue, rows);
		}
	}
}
