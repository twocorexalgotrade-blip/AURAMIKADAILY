#!/bin/bash

# Script to copy assets from Flutter app to web

SOURCE_DIR="/Users/smitbhoir/SwarnaSetu/swarna_setu_user/assets/images"
DEST_DIR="/Users/smitbhoir/SwarnaSetu/swarna_setu_web/assets/images"

echo "Copying assets from Flutter app to web..."

# Create destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Copy logo
cp "$SOURCE_DIR/logo.png" "$DEST_DIR/" 2>/dev/null && echo "✓ Copied logo.png"

# Copy product images
cp "$SOURCE_DIR/gold_ring.jpg" "$DEST_DIR/" 2>/dev/null && echo "✓ Copied gold_ring.jpg"
cp "$SOURCE_DIR/earring1.jpg" "$DEST_DIR/" 2>/dev/null && echo "✓ Copied earring1.jpg"
cp "$SOURCE_DIR/Pendant1.jpg" "$DEST_DIR/" 2>/dev/null && echo "✓ Copied Pendant1.jpg"
cp "$SOURCE_DIR/storefront_bg.png" "$DEST_DIR/" 2>/dev/null && echo "✓ Copied storefront_bg.png"

# Copy all pendant images for variety
cp "$SOURCE_DIR"/Pendant*.jpg "$DEST_DIR/" 2>/dev/null && echo "✓ Copied pendant variations"
cp "$SOURCE_DIR"/*Anklet*.jpg "$DEST_DIR/" 2>/dev/null && echo "✓ Copied anklet images"
cp "$SOURCE_DIR"/*Nose*.jpg "$DEST_DIR/" 2>/dev/null && echo "✓ Copied nose pin images"
cp "$SOURCE_DIR"/*Tikka*.jpg "$DEST_DIR/" 2>/dev/null && echo "✓ Copied tikka images"
cp "$SOURCE_DIR"/*Belt*.jpg "$DEST_DIR/" 2>/dev/null && echo "✓ Copied belt images"

# Copy directories
echo "Copying directories..."
cp -r "$SOURCE_DIR/collections" "$DEST_DIR/" 2>/dev/null && echo "✓ Copied collections/"
cp -r "$SOURCE_DIR/new_iconic_collections" "$DEST_DIR/" 2>/dev/null && echo "✓ Copied new_iconic_collections/"
cp -r "$SOURCE_DIR/top_selling" "$DEST_DIR/" 2>/dev/null && echo "✓ Copied top_selling/"
cp -r "$SOURCE_DIR/top_selling_jewellery" "$DEST_DIR/" 2>/dev/null && echo "✓ Copied top_selling_jewellery/"
cp -r "$SOURCE_DIR/ornament_section" "$DEST_DIR/" 2>/dev/null && echo "✓ Copied ornament_section/"
cp -r "$SOURCE_DIR/popular_jewellers" "$DEST_DIR/" 2>/dev/null && echo "✓ Copied popular_jewellers/"
cp -r "$SOURCE_DIR/material_section" "$DEST_DIR/" 2>/dev/null && echo "✓ Copied material_section/"
cp -r "$SOURCE_DIR/gender_section" "$DEST_DIR/" 2>/dev/null && echo "✓ Copied gender_section/"

echo ""
echo "Asset copy complete!"
echo "Total files copied: $(find "$DEST_DIR" -type f | wc -l)"
