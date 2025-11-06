import React, { useRef } from "react";

function PopupPost({ onClose, onUpload }) {
  const fileInputRef = useRef(null);

  return (
    <div className="absolute inset-0 z-30 flex items-center justify-center">
      {/* Backdrop within main only */}
      <div
        className="absolute inset-0 bg-black/50"
        onClick={onClose}
        aria-hidden="true"
      />

      {/* Dialog */}
      <div
        role="dialog"
        aria-modal="true"
        className="relative w-[680px] max-w-[92%] bg-white rounded-2xl shadow-2xl border border-gray-200 overflow-hidden"
      >
        {/* Header */}
        <div className="relative items-center justify-center px-6 py-4 border-b">
          <h2 className="absolute left-1/2 transform -translate-x-1/2 text-xl font-bold text-gray-900">Upload Design</h2>
          <button
            type="button"
            onClick={onClose}
            className="absolute top-4 right-4 text-gray-600 hover:text-gray-900 text-2xl leading-none"
            aria-label="Close"
          >
            ×
          </button>
        </div>
        <div className="w-px bg-gray-900 my-10"></div>
        {/* Body */}
        <div className="px-6 pt-5 pb-6 space-y-4">
          <div className="flex items-center gap-3 text-gray-900">
            <span className="inline-flex items-center justify-center w-9 h-9 rounded-full bg-gray-200">👤</span>
            <span className="font-medium">Jzar Alaba</span>
          </div>

          <textarea
            className="w-full h-28 border rounded-lg px-3 py-2 resize-none focus:outline-none focus:ring-2 focus:ring-gray-300"
            placeholder="Write a caption..."
          />

          {/* Images row */}
          <div className="flex items-center gap-3">
            <button
              type="button"
              onClick={() => fileInputRef.current?.click()}
              className="px-3 py-2 border rounded-lg text-sm hover:bg-gray-50"
            >
              + Add Images
            </button>
            <input ref={fileInputRef} type="file" multiple className="hidden" />

            {/* Thumbnails placeholders */}
            <div className="flex items-center gap-2 overflow-x-auto">
              {[1, 2, 3, 4, 5].map((n) => (
                <div
                  key={n}
                  className="w-16 h-16 rounded-lg overflow-hidden bg-gray-200 flex items-center justify-center text-gray-500 text-sm"
                >
                  Img
                </div>
              ))}
            </div>
          </div>

          <button type="button" className="px-3 py-2 border rounded-lg text-sm hover:bg-gray-50">
            + Add Tags
          </button>
        </div>

        {/* Footer */}
        <div className="px-6 pb-6">
          <button
            type="button"
            onClick={onUpload}
            className="w-full py-3 rounded-xl bg-black text-white font-medium hover:opacity-90"
          >
            Upload
          </button>
        </div>
      </div>
    </div>
  );
}

export default PopupPost;


