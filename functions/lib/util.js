"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.phtDateLabel = phtDateLabel;
exports.itemKey = itemKey;
exports.emptyChannel = emptyChannel;
exports.addToChannel = addToChannel;
/** Philippines is UTC+8. Returns 'YYYY-MM-DD'. */
function phtDateLabel(d = new Date()) {
    const pht = new Date(d.getTime() + 8 * 60 * 60 * 1000);
    const m = String(pht.getUTCMonth() + 1).padStart(2, "0");
    const day = String(pht.getUTCDate()).padStart(2, "0");
    return `${pht.getUTCFullYear()}-${m}-${day}`;
}
/** Composite item key including variant: 'Name (Variant)' or 'Name'. */
function itemKey(name, variant) {
    return variant ? `${name} (${variant})` : name;
}
function emptyChannel() {
    const zero = () => ({ revenue: 0, count: 0 });
    return { walkIn: zero(), delivery: zero(), pickup: zero() };
}
/** Adds an order total to the matching channel bucket (Pickup default). */
function addToChannel(b, orderType, amount) {
    const bucket = orderType === "Walk-In" ? b.walkIn :
        orderType === "Delivery" ? b.delivery : b.pickup;
    bucket.revenue += amount;
    bucket.count += 1;
}
//# sourceMappingURL=util.js.map