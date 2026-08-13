import mongoose from "mongoose";

const hydrationSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true
    },

    waterLitres: {
      type: Number,
      required: true,
      min: [0, "Water litres cannot be negative"],
      set: (v) => Math.round(v * 100) / 100
    },

    date: {
      type: Date,
      required: true
    }
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
  }
);

hydrationSchema.index({ user: 1, date: 1 }, { unique: true });

const Hydration = mongoose.model("Hydration", hydrationSchema);

export default Hydration;
