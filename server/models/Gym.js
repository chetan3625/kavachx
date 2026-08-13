import mongoose from "mongoose";

const gymSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true
    },

    ownerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    phone: {
      type: String,
      trim: true
    },

    address: {
      type: String,
      trim: true
    },

    gymToken: {
      type: String,
      unique: true,
      required: true
    },

    qrUrl: {
      type: String,
      default: null
    },

    isActive: {
      type: Boolean,
      default: true
    },
    
    qrUrl: {
      type: String
    }
  },
  {
    timestamps: true
  }
);

const Gym = mongoose.model("Gym", gymSchema);

export default Gym;
