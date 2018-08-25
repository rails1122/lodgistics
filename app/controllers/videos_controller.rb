class VideosController < ActionController::Base
  def how_to_videos
    render json: [
        {
            "name": "Logging In & Welcome screen",
            "description": "",
            "path": "https://img.youtube.com/vi/JPQMSyqMVGU/default.jpg",
            "id": "JPQMSyqMVGU"
        },
        {
            "name": "Creating a New Hotel Log Post",
            "description": "",
            "path": "https://img.youtube.com/vi/Lp0DcnR7A_M/default.jpg",
            "id": "Lp0DcnR7A_M"
        },
        {
            "name": "Creating WO (Public Area) from Guest Log Post",
            "description": "",
            "path": "https://img.youtube.com/vi/K8R-4pvPdvU/default.jpg",
            "id": "K8R-4pvPdvU"
        },
        {
            "name": "Broadcast a new created Guest Log Post",
            "description": "",
            "path": "https://img.youtube.com/vi/3ti_nImOtoc/default.jpg",
            "id": "3ti_nImOtoc"
        },
        {
            "name": "Messaging | Create New Message Group",
            "description": "",
            "path": "https://img.youtube.com/vi/sTWFB7GHJMQ/default.jpg",
            "id": "sTWFB7GHJMQ"
        },
        {
            "name": "Messaging | Notification for being added to a new group",
            "description": "",
            "path": "https://img.youtube.com/vi/9d0bJ-sqmQE/default.jpg",
            "id": "9d0bJ-sqmQE"
        },
        {
            "name": "Messaging | Receive Messages & Respond to a particular message",
            "description": "",
            "path": "https://img.youtube.com/vi/Zc9-O-mACSo/default.jpg",
            "id": "Zc9-O-mACSo"
        },
        {
            "name": "Messaging | Mentioning Users",
            "description": "",
            "path": "https://img.youtube.com/vi/Rs-r6W1DTv8/default.jpg",
            "id": "Rs-r6W1DTv8"
        },
        {
            "name": "Messaging | Notification after getting mentioned & Work Order workflow",
            "description": "",
            "path": "https://img.youtube.com/vi/WtDlTxLJmfs/default.jpg",
            "id": "WtDlTxLJmfs"
        }
    ]
  end
end