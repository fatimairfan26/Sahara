const mongoose = require('mongoose');
const StoreInfo = require('../model/storeinfo.model');
const Todo = require("../model/todo.model");
const { usermodel, imageModel } = require('../model/user.model');
const { Accepted, Rejected } = require('../model/matrimonial.model');
const express = require('express');
const cors = require('cors');
const app = express();
app.use(cors());

// Function to provide suggestions to the user based on their preferences
exports.provideSuggestions = async (req, res) => {
    const { userId } = req.params;
    console.log("User ID extracted from request:", userId);

    try {
        // Fetch user preferences from Todo model
        const userPreferences = await Todo.findOne({ userId });

        // Fetch user information including gender from StoreInfo model
        const userInfo = await StoreInfo.findOne({ userId });

        // Extract user gender from userInfo
        const userGender = userInfo.gender;
        console.log("User gender:", userGender);

        // Fetch IDs of accepted and rejected profiles by the user
        const acceptedProfiles = await Accepted.find({ userId });
        const acceptedProfileIds = acceptedProfiles.map(check => check.profileId);

        const rejectedProfiles = await Rejected.find({ userId });
        const rejectedProfileIds = rejectedProfiles.map(check => check.profileId);

        // Fetch all user profiles
        let allUserProfiles = await StoreInfo.find();

        // Calculate and sort suggestions
        const suggestions = await calculateAndSortSuggestions(userPreferences, allUserProfiles, userGender, acceptedProfileIds, rejectedProfileIds);

        res.json(suggestions);
    } catch (error) {
        console.error("Error providing suggestions:", error);
        res.status(500).json({ error: "Internal Server Error" });
    }
}

// Function to accept a user suggestion
exports.acceptUser = async (req, res) => {
    const { userId, profileId } = req.params;

    try {
        // Store the accepted user in the Accepted collection
        await Accepted.create({ userId, profileId });
        res.json({ message: "User accepted successfully." });
    } catch (error) {
        console.error("Error accepting user:", error);
        res.status(500).json({ error: "Internal Server Error" });
    }
}

// Function to reject a user suggestion
exports.rejectUser = async (req, res) => {
    const { userId, profileId } = req.params;

    try {
        // Store the rejected user in the Rejected collection
        await Rejected.create({ userId, profileId });
        res.json({ message: "User rejected successfully." });
    } catch (error) {
        console.error("Error rejecting user:", error);
        res.status(500).json({ error: "Internal Server Error" });
    }
}

// Function to calculate compatibility score between user preferences and profile
function calculateCompatibilityScore(userPreferences, profile) {
    let compatibilityScore = 0;

    if (userPreferences.religion === profile.religion) compatibilityScore++;
    if (userPreferences.nationality === profile.nationality) compatibilityScore++;
    if (userPreferences.city === profile.city) compatibilityScore++;
    if (userPreferences.height === profile.height) compatibilityScore++;
    if (userPreferences.marital_status === profile.marital_status) compatibilityScore++;
    if (userPreferences.education === profile.education) compatibilityScore++;
    if (userPreferences.occupation === profile.occupation) compatibilityScore++;
    return compatibilityScore;
}

async function calculateAndSortSuggestions(userPreferences, allUserProfiles, userGender, acceptedProfileIds, rejectedProfileIds) {
    const suggestions = [];

    for (const profile of allUserProfiles) {
        if (userGender !== profile.gender && !rejectedProfileIds.some(id => id.equals(profile.userId)) && !acceptedProfileIds.some(id => id.equals(profile.userId))) {
            const compatibilityScore = calculateCompatibilityScore(userPreferences, profile);

            // Fetch username from user data using userID
            const user = await usermodel.findById(profile.userId);
            const username = user ? user.username : "Unknown"; // Default to "Unknown" if user not found

            // Fetch the latest image saved by the user
            const latestImage = await imageModel.findOne({ userId: profile.userId, check: 'post' }).sort({ _id: -1 }).select('imagePath');

            // Add the image path to the suggestions
            const imagePath = latestImage ? latestImage.imagePath : "None Uploaded";

            suggestions.push({
                puserId: profile.userId,
                username: username,
                pbio: profile.bio,
                pcity: profile.city,
                pmarital: profile.marital,
                compatibilityScore: compatibilityScore,
                imagePath: imagePath 
            });
        }
    }

    // Sort suggestions based on compatibility score (highest to lowest)
    suggestions.sort((a, b) => b.compatibilityScore - a.compatibilityScore);

    return suggestions; 
}